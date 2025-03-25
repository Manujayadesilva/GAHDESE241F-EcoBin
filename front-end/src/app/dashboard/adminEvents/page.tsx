"use client";

import { useEffect, useState } from "react";
import Sidebar from "../../../components/Sidebar";
import { fetchCollection, addItem, deleteItem } from "../../../firebase/db";

const AdminEventsUpdates = () => {
  const [events, setEvents] = useState<any[]>([]);
  const [updates, setUpdates] = useState<any[]>([]);
  const [newEvent, setNewEvent] = useState("");
  const [newUpdate, setNewUpdate] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      setEvents(await fetchCollection("events"));
      setUpdates(await fetchCollection("updates"));
    };
    fetchData();
  }, []);

  // Add Event
  const handleAddEvent = async () => {
    if (newEvent.trim()) {
      await addItem("events", { title: newEvent, date: new Date().toISOString() });
      setEvents(await fetchCollection("events"));
      setNewEvent("");
    }
  };

  // Add Update
  const handleAddUpdate = async () => {
    if (newUpdate.trim()) {
      await addItem("updates", { title: newUpdate });
      setUpdates(await fetchCollection("updates"));
      setNewUpdate("");
    }
  };

  // Delete Event or Update
  const handleDelete = async (collection: string, id: string) => {
    await deleteItem(collection, id);
    if (collection === "events") setEvents(await fetchCollection("events"));
    else setUpdates(await fetchCollection("updates"));
  };

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Manage Events & Updates</h1>

        {/* Events Section */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold mb-4">Upcoming Events</h2>
          <input
            type="text"
            placeholder="Enter event title"
            className="border p-2 rounded w-full mb-2"
            value={newEvent}
            onChange={(e) => setNewEvent(e.target.value)}
          />
          <button onClick={handleAddEvent} className="bg-blue-500 text-white p-2 rounded w-full">Add Event</button>
          <ul>
            {events.map((event) => (
              <li key={event.id} className="p-3 border-b flex justify-between">
                {event.title} - {new Date(event.date).toLocaleDateString()}
                <button onClick={() => handleDelete("events", event.id)} className="text-red-500">Delete</button>
              </li>
            ))}
          </ul>
        </div>

        {/* Updates Section */}
        <div className="bg-white p-6 rounded-lg shadow-md mt-6">
          <h2 className="text-xl font-bold mb-4">Latest Updates</h2>
          <input
            type="text"
            placeholder="Enter update"
            className="border p-2 rounded w-full mb-2"
            value={newUpdate}
            onChange={(e) => setNewUpdate(e.target.value)}
          />
          <button onClick={handleAddUpdate} className="bg-blue-500 text-white p-2 rounded w-full">Add Update</button>
          <ul>
            {updates.map((update) => (
              <li key={update.id} className="p-3 border-b flex justify-between">
                {update.title}
                <button onClick={() => handleDelete("updates", update.id)} className="text-red-500">Delete</button>
              </li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
};

export default AdminEventsUpdates;
