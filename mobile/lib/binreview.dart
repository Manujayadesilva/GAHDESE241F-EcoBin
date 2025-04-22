import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BinReviewPage extends StatefulWidget {
  const BinReviewPage({Key? key}) : super(key: key);

  @override
  _BinReviewPageState createState() => _BinReviewPageState();
}

class _BinReviewPageState extends State<BinReviewPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 0;
  String _reviewText = '';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Color get _primaryColor => Colors.green.shade600;
  Color get _backgroundColor => Colors.white;

  void _selectRating(int rating) {
    setState(() {
      _rating = rating.toDouble();
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('Please log in to submit a review');
      return;
    }

    try {
      Map<String, dynamic> reviewData = {
        'name':
            currentUser.displayName ?? currentUser.email ?? 'Anonymous User',
        'userId': currentUser.uid,
        'rating': _rating,
        'comment': _reviewText.trim(),
        'date': FieldValue.serverTimestamp(),
        'hasImage': _image != null,
      };

      if (_image != null) {
        final String fileName =
            'reviews/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
        final Reference storageRef = _storage.ref().child(fileName);
        await storageRef.putFile(_image!);
        final String imageUrl = await storageRef.getDownloadURL();
        reviewData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('reviews').add(reviewData);

      _resetForm();
      _showSuccessSnackBar('Review submitted successfully');
    } catch (e) {
      _showErrorSnackBar('Error submitting review: $e');
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _rating = 0;
      _reviewText = '';
      _image = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('Rate & Reviews', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: _primaryColor,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRatingSection(),
                const SizedBox(height: 16),
                _buildReviewInput(),
                const SizedBox(height: 16),
                _buildImageUploadSection(),
                const SizedBox(height: 16),
                _buildSubmitButton(),
                const SizedBox(height: 24),
                _buildReviewsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: _primaryColor,
            size: 40,
          ),
          onPressed: () => _selectRating(index + 1),
        );
      }),
    );
  }

  Widget _buildReviewInput() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Write your review here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a review';
        }
        return null;
      },
      onSaved: (value) => _reviewText = value ?? '',
    );
  }

  Widget _buildImageUploadSection() {
    return SizedBox(
      height: 48, // Reduced height
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.image, color: Colors.white),
        label: Text(
          _image == null ? 'Upload Image (Optional)' : 'Image Selected',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _image == null ? _primaryColor : Colors.green,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48, // Reduced height
      child: ElevatedButton(
        onPressed: _submitReview,
        style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
        child: const Text(
          'Submit Review',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('reviews')
                  .orderBy('date', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No reviews yet'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> reviewData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return _buildReviewCard(reviewData);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    // Null-safe handling of review data
    final String userName = review['name'] ?? 'Anonymous User';
    final double rating = (review['rating'] ?? 0.0).toDouble();
    final String comment = review['comment'] ?? 'No comments available';
    final bool hasImage = review['hasImage'] == true;
    final String? imageUrl = hasImage ? review['imageUrl'] : null;

    // Admin response data
    final bool hasAdminResponse = review['adminResponse'] != null;
    final String? adminResponse = review['adminResponse'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: _primaryColor,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment),
            if (hasImage && imageUrl != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

            // Admin response section - only displayed if there's an admin response
            if (hasAdminResponse && adminResponse != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Response:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(adminResponse),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
