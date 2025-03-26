"use client";

import { useEffect, useState } from "react";
import Sidebar from "../../../components/Sidebar";
import { getEvents, getUpdates, addEvent, deleteEvent } from "../../../firebase/db";

const EventsUpdates = () => {
  const [events, setEvents] = useState<any[]>([]);
  const [updates, setUpdates] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [newEvent, setNewEvent] = useState({
    title: "",
    date: "",
    time: "",
    location: "",
    description: "",
  });

  // ✅ Fetch Events & Updates
  useEffect(() => {
    const fetchData = async () => {
      try {
        const eventsData = await getEvents();
        const updatesData = await getUpdates();
        setEvents(eventsData);
        setUpdates(updatesData);
      } catch (error) {
        console.error("Error fetching events/updates:", error);
      }
    };
    fetchData();
  }, []);

  // ✅ Add New Event
  const handleAddEvent = async () => {
    if (!newEvent.title || !newEvent.date || !newEvent.time || !newEvent.location || !newEvent.description) {
      alert("Please fill all fields.");
      return;
    }
    setLoading(true);
    try {
      const newEventData = { ...newEvent, createdAt: new Date() }; // Add timestamp
      await addEvent(newEventData);
      setEvents((prev) => [...prev, newEventData]); // Update local state directly
      setNewEvent({ title: "", date: "", time: "", location: "", description: "" });
    } catch (error) {
      console.error("Error adding event:", error);
    } finally {
      setLoading(false);
    }
  };

  // ✅ Delete Event
  const handleDeleteEvent = async (id: string) => {
    if (!confirm("Are you sure you want to delete this event?")) return;
    try {
      await deleteEvent(id);
      setEvents((prev) => prev.filter((event) => event.id !== id)); // Remove from state
    } catch (error) {
      console.error("Error deleting event:", error);
    }
  };

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-6">Events & Updates</h1>

        {/* ✅ Add New Event */}
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-bold mb-4">Add New Event</h2>
          <input type="text" placeholder="Event Title" className="w-full p-2 border rounded mb-2"
            value={newEvent.title} onChange={(e) => setNewEvent({ ...newEvent, title: e.target.value })} />
          <input type="date" className="w-full p-2 border rounded mb-2"
            value={newEvent.date} onChange={(e) => setNewEvent({ ...newEvent, date: e.target.value })} />
          <input type="time" className="w-full p-2 border rounded mb-2"
            value={newEvent.time} onChange={(e) => setNewEvent({ ...newEvent, time: e.target.value })} />
          <input type="text" placeholder="Location" className="w-full p-2 border rounded mb-2"
            value={newEvent.location} onChange={(e) => setNewEvent({ ...newEvent, location: e.target.value })} />
          <textarea placeholder="Description" className="w-full p-2 border rounded mb-2"
            value={newEvent.description} onChange={(e) => setNewEvent({ ...newEvent, description: e.target.value })}></textarea>
          <button onClick={handleAddEvent} className={`bg-green-500 text-white p-2 rounded ${loading ? "opacity-50 cursor-not-allowed" : ""}`} disabled={loading}>
            {loading ? "Adding..." : "Add Event"}
          </button>
        </div>

        {/* ✅ Events List */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold mb-4">Upcoming Events</h2>
          {events.length === 0 ? <p>No upcoming events.</p> : (
            events.map((event) => (
              <div key={event.id} className="p-4 mb-4 bg-green-50 rounded-lg shadow">
                <h3 className="text-lg font-semibold">{event.title}</h3>
                <p className="text-sm text-gray-600">{event.date} | {event.time}</p>
                <p className="text-sm text-gray-700">{event.location}</p>
                <p className="text-gray-800">{event.description}</p>
                <button onClick={() => handleDeleteEvent(event.id)} className="mt-2 bg-red-500 text-white px-3 py-1 rounded">
                  Delete
                </button>
              </div>
            ))
          )}
        </div>
      </main>
    </div>
  );
};

export default EventsUpdates;
