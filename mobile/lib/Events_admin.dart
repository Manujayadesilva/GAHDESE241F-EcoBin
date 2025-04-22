import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({Key? key}) : super(key: key);

  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  // Controllers for form inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Firestore reference
  final CollectionReference _eventsCollection = FirebaseFirestore.instance
      .collection('events');

  // Date and Time Pickers
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  // Add new event to Firestore
  Future<void> _addNewEvent() async {
    try {
      await _eventsCollection.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear controllers and close dialog
      _clearControllers();
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Event added successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
    }
  }

  // Update existing event
  Future<void> _updateEvent(String docId) async {
    try {
      await _eventsCollection.doc(docId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': _dateController.text,
        'time': _timeController.text,
      });

      _clearControllers();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Event updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update event: $e')));
    }
  }

  // Delete event
  Future<void> _deleteEvent(String docId) async {
    try {
      await _eventsCollection.doc(docId).delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Event deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
    }
  }

  // Clear form controllers
  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _dateController.clear();
    _timeController.clear();
  }

  // Show event dialog (for both add and edit)
  void _showEventDialog({String? docId, Map<String, dynamic>? eventData}) {
    // Pre-fill controllers if editing
    if (eventData != null) {
      _titleController.text = eventData['title'] ?? '';
      _descriptionController.text = eventData['description'] ?? '';
      _locationController.text = eventData['location'] ?? '';
      _dateController.text = eventData['date'] ?? '';
      _timeController.text = eventData['time'] ?? '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(docId == null ? 'Create New Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Event Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                ),
                TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearControllers();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (docId == null) {
                  _addNewEvent();
                } else {
                  _updateEvent(docId);
                }
              },
              child: Text(docId == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEventDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var event = snapshot.data!.docs[index];
              var eventData = event.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    eventData['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${eventData['date']}'),
                      Text('Time: ${eventData['time']}'),
                      Text('Location: ${eventData['location']}'),
                      Text(eventData['description']),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            () => _showEventDialog(
                              docId: event.id,
                              eventData: eventData,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEvent(event.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
