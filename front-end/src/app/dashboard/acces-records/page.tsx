"use client";

import { useEffect, useState } from "react";
import { getAllAccessRecordsWithUserDetails } from "@/firebase/db";
import Sidebar from "@/components/Sidebar";

interface AccessRecord {
  id: string;
  binID: string;
  location: string;
  timestamp: string;
  user: {
    name: string;
    email: string;
  };
}

const AdminAccessPage = () => {
  const [records, setRecords] = useState<AccessRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedBin, setSelectedBin] = useState<string>("all");

  useEffect(() => {
    const fetchRecords = async () => {
      const data = await getAllAccessRecordsWithUserDetails();
      setRecords(data);
      setLoading(false);
    };
    fetchRecords();
  }, []);

  const filteredRecords =
    selectedBin === "all"
      ? records
      : records.filter((record) => record.binID === selectedBin);

  const uniqueBins = Array.from(new Set(records.map((r) => r.binID)));

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="fixed top-0 left-0 h-full w-64 z-50">
        <Sidebar />
      </div>
      <main className="ml-64 p-6">
        <h1 className="text-2xl font-bold mb-4">Bin Access Records</h1>

        {/* Bin Selector */}
        <div className="mb-4">
          <label className="block mb-2 text-sm font-medium">Filter by Bin:</label>
          <select
            value={selectedBin}
            onChange={(e) => setSelectedBin(e.target.value)}
            className="bg-gray-800 border border-gray-600 text-white py-2 px-4 rounded"
          >
            <option value="all">All Bins</option>
            {uniqueBins.map((binID) => (
              <option key={binID} value={binID}>
                {binID}
              </option>
            ))}
          </select>
        </div>

        {loading ? (
          <p>Loading access records...</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full bg-gray-800 text-left text-sm">
              <thead>
                <tr className="bg-gray-700 text-white">
                  <th className="py-2 px-4">User</th>
                  <th className="py-2 px-4">Email</th>
                  <th className="py-2 px-4">Bin ID</th>
                  <th className="py-2 px-4">Location</th>
                  <th className="py-2 px-4">Timestamp</th>
                </tr>
              </thead>
              <tbody>
                {filteredRecords.map((record) => (
                  <tr
                    key={record.id}
                    className="border-b border-gray-600 hover:bg-gray-700"
                  >
                    <td className="py-2 px-4">{record.user.name}</td>
                    <td className="py-2 px-4">{record.user.email}</td>
                    <td className="py-2 px-4">{record.binID}</td>
                    <td className="py-2 px-4">{record.location}</td>
                    <td className="py-2 px-4">{record.timestamp}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {filteredRecords.length === 0 && (
              <p className="text-sm mt-4 text-gray-400">No records found for selected bin.</p>
            )}
          </div>
        )}
      </main>
    </div>
  );
};

export default AdminAccessPage;
