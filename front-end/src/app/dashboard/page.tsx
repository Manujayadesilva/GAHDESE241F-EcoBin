"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Sidebar from "../../components/Sidebar";
import { fetchBinsData, getCurrentUser } from "../../firebase/db";
import { Doughnut, Bar } from "react-chartjs-2";
import { Chart, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement } from "chart.js";
import GoogleMapComponent from "@/components/GoogleMap";

Chart.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement);

const UserDashboard = () => {
  const [bins, setBins] = useState<any>(null);
  const [profileImage, setProfileImage] = useState<string | null>(null);

  useEffect(() => {
    fetchBinsData(setBins);
    loadUserProfile();
  }, []);

  const loadUserProfile = async () => {
    const user = await getCurrentUser();
    if (user && user.profilePicture) {
      setProfileImage(user.profilePicture);
    } else {
      setProfileImage("/default-profile.png"); // fallback image
    }
  };

  if (!bins) return <p className="text-center mt-10">Loading bins data...</p>;

  const binLevels = Object.values(bins).map((bin: any) => bin.wasteLevel);
  const binLocations = Object.values(bins).map((bin: any) => bin.location);
  const fullBins = binLevels.filter((level) => level >= 80).length;
  const halfBins = binLevels.filter((level) => level >= 40 && level < 80).length;
  const lowBins = binLevels.filter((level) => level < 40).length;
  const avgFillLevel = (binLevels.reduce((a, b) => a + b, 0) / binLevels.length).toFixed(1);

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        {/* Top Right Profile */}
        <div className="absolute top-6 right-8">
          <div className="relative group">
            <img
              src={profileImage || "/default-profile.png"}
              alt="Profile"
              width={40}
              height={40}
              className="rounded-full border-2 border-gray-300 cursor-pointer object-cover"
            />
            <div className="absolute right-0 mt-2 w-32 bg-white shadow-md rounded-md opacity-0 group-hover:opacity-100 transition-opacity z-10">
              <button
                onClick={() => {
                  import("@/firebase/auth").then((mod) => {
                    mod.logout();
                    window.location.replace("/");
                  });
                }}
                className="block w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-gray-100"
              >
                Logout
              </button>
            </div>
          </div>
        </div>

        <h1 className="text-3xl font-bold mb-4">User Dashboard</h1>
        <p className="text-gray-600">Track your waste bins and access services.</p>

        {/* Bin Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold">Total Bins</h2>
            <p className="text-2xl font-semibold">{Object.keys(bins).length}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold">Full Bins</h2>
            <p className="text-2xl font-semibold">{fullBins}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold">Average Fill Level</h2>
            <p className="text-2xl font-semibold">{avgFillLevel}%</p>
          </div>
        </div>

        {/* Map */}
        <div className="bg-white p-6 rounded-lg shadow mt-8">
          <h2 className="text-xl font-bold mb-4">Bin Locations</h2>
          <GoogleMapComponent />
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold mb-4">Bin Fill Levels</h2>
            <Doughnut
              data={{
                labels: ["Full (80-100%)", "Half-Full (40-79%)", "Low (0-39%)"],
                datasets: [
                  {
                    label: "Bins",
                    data: [fullBins, halfBins, lowBins],
                    backgroundColor: ["#ff4d4d", "#ffcc00", "#66cc66"],
                  },
                ],
              }}
            />
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold mb-4">Waste Levels by Location</h2>
            <Bar
              data={{
                labels: binLocations,
                datasets: [
                  {
                    label: "Fill Level (%)",
                    data: binLevels,
                    backgroundColor: "#007bff",
                  },
                ],
              }}
              options={{
                responsive: true,
                scales: {
                  y: {
                    beginAtZero: true,
                    max: 100,
                    title: {
                      display: true,
                      text: "Fill Level (%)",
                    },
                  },
                },
              }}
            />
          </div>
        </div>
      </main>
    </div>
  );
};

export default UserDashboard;
