"use client";

import { useEffect, useState } from "react";
import Sidebar from "../../../components/Sidebar";
import { getEvents, registerForEvent, cancelRegistration, deleteEvent, getUserRole } from "../../../firebase/db";
import { useAuth } from "../../../firebase/authContext"; // Ensure you have authentication context

const EventsUpdates = () => {
  const [events, setEvents] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [userRole, setUserRole] = useState<string | null>(null);
  const auth = useAuth(); 
  const user = auth?.currentUser;

  // ✅ Fetch Events & User Role
  useEffect(() => {
    const fetchData = async () => {
      try {
        const eventsData = await getEvents();
        setEvents(eventsData);
        if (user) {
          const role = await getUserRole(user.uid);
          setUserRole(role);
        }
      } catch (error) {
        console.error("Error fetching data:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [user]);

  // ✅ Handle Event Registration
const handleRegister = async (eventId: string) => {
  if (!user) return;
  try {
    await registerForEvent(eventId, user.uid);

    // ✅ Update local state
    setEvents((prev) =>
      prev.map((event) =>
        event.id === eventId
          ? { ...event, participants: [...(event.participants || []), user.uid] }
          : event
      )
    );
  } catch (error) {
    console.error("Error registering:", error);
  }
};


  // ✅ Handle Cancel Registration
  const handleCancel = async (eventId: string) => {
    if (!user) return;
    try {
      await cancelRegistration(eventId, user.uid);
      setEvents((prev) =>
        prev.map((event) =>
          event.id === eventId ? { ...event, participants: event.participants.filter((id: any) => id !== user.uid) } : event
        )
      );
    } catch (error) {
      console.error("Error canceling registration:", error);
    }
  };

  // ✅ Handle Event Deletion (Admin Only)
  const handleDelete = async (eventId: string) => {
    if (!user || userRole !== "admin") return;
    try {
      await deleteEvent(eventId);
      setEvents((prev) => prev.filter((event) => event.id !== eventId));
    } catch (error) {
      console.error("Error deleting event:", error);
    }
  };

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Events & Updates</h1>

        {loading ? (
          <p>Loading events...</p>
        ) : (
          <div className="grid gap-6">
            {events.map((event) => (
              <div key={event.id} className="bg-white p-6 rounded-lg shadow-md">
                <div className="flex items-center justify-between">
                  <h2 className="text-lg font-bold text-green-700">{event.title}</h2>
                  <span className="text-gray-500">{event.date}</span>
                </div>
                <p className="text-gray-700 mt-2">{event.description}</p>

                <div className="flex items-center mt-4 text-gray-600">
                  <span className="mr-4">📍 {event.location}</span>
                  <span>⏰ {event.time}</span>
                </div>

                <div className="flex items-center justify-between mt-4">
                  {event.participants?.includes(user?.uid) ? (
                    <button
                      onClick={() => handleCancel(event.id)}
                      className="bg-gray-300 text-gray-700 px-4 py-2 rounded-md"
                    >
                      Cancel
                    </button>
                  ) : (
                    <button
                      onClick={() => handleRegister(event.id)}
                      className="bg-green-600 text-white px-4 py-2 rounded-md"
                    >
                      Register
                    </button>
                  )}

                  {userRole === "admin" && (
                    <button
                      onClick={() => handleDelete(event.id)}
                      className="bg-red-500 text-white px-4 py-2 rounded-md"
                    >
                      Delete Event
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
};

export default EventsUpdates;
