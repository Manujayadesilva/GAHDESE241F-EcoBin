"use client";

import { useEffect, useState } from "react";
import Sidebar from "../../../components/Sidebar";
import { getEvents, getUpdates } from "../../../firebase/db";

const EventsUpdates = () => {
  const [events, setEvents] = useState<any[]>([]);
  const [updates, setUpdates] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      setEvents(await getEvents());
      setUpdates(await getUpdates());
    };
    fetchData();
  }, []);

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Events & Updates</h1>

        {/* Events */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold mb-4">Upcoming Events</h2>
          <ul>
            {events.map((event) => (
              <li key={event.id} className="p-3 border-b">{event.title} - {event.date}</li>
            ))}
          </ul>
        </div>

        {/* Updates */}
        <div className="bg-white p-6 rounded-lg shadow-md mt-6">
          <h2 className="text-xl font-bold mb-4">Latest Updates</h2>
          <ul>
            {updates.map((update) => (
              <li key={update.id} className="p-3 border-b">{update.title}</li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
};

export default EventsUpdates;
