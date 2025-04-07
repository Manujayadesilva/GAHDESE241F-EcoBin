// app/dashboard/adminAccess/page.tsx

"use client";

import { useEffect, useState } from "react";
import { getAllAccessRecordsWithUserDetails } from "@/firebase/db";
import Image from "next/image";

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
  
  useEffect(() => {
    const fetchRecords = async () => {
      const data = await getAllAccessRecordsWithUserDetails();
      setRecords(data);
      setLoading(false);
    };
    fetchRecords();
  }, []);

  if (loading) return <p className="text-white p-6">Loading access records...</p>;

  return (
    <div className="p-6 text-white">
      <h1 className="text-2xl font-bold mb-4">Bin Access Records</h1>
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
            {records.map((record) => (
              <tr key={record.id} className="border-b border-gray-600 hover:bg-gray-700">
                <td className="py-2 px-4">{record.user.name}</td>
                <td className="py-2 px-4">{record.user.email}</td>
                <td className="py-2 px-4">{record.binID}</td>
                <td className="py-2 px-4">{record.location}</td>
                <td className="py-2 px-4">{record.timestamp}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default AdminAccessPage;
