"use client";

import { useEffect, useState } from "react";
import { getBins, getBinHistory } from "../../../firebase/db";
import Sidebar from "../../../components/Sidebar";
import { Line } from "react-chartjs-2";
import Papa from "papaparse";
import { saveAs } from "file-saver";
import {
  Chart as ChartJS,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
} from "chart.js";

// Register Chart.js components
ChartJS.register(LineElement, PointElement, CategoryScale, LinearScale, Tooltip, Legend);

type Bin = {
  id: string;
  location: string;
  wasteLevel: number;
  status: string;
  lat: number;
  lng: number;
};

type HistoryRecord = {
  id: string;
  timestamp: any;
  wasteLevel: number;
  status: string;
  lat?: number;
  lng?: number;
};

const BinsPage = () => {
  const [bins, setBins] = useState<Bin[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedBin, setSelectedBin] = useState<string | null>(null);
  const [history, setHistory] = useState<HistoryRecord[]>([]);
  const [historyLoading, setHistoryLoading] = useState(false);

  useEffect(() => {
    const fetchBins = async () => {
      try {
        const rawBinsData = await getBins();
        const binsData: Bin[] = rawBinsData.map((bin: Partial<Bin>) => ({
          id: bin.id ?? "",
          location: bin.location ?? "Unknown",
          wasteLevel: bin.wasteLevel ?? 0,
          status: bin.status ?? "Unknown",
          lat: bin.lat ?? 0,
          lng: bin.lng ?? 0,
        }));
        setBins(binsData);

        // Alert if any bin is full
        binsData.forEach((bin) => {
          if (bin.status === "Full") {
            alert(`⚠️ Bin at ${bin.location} is FULL!`);
          }
        });
      } catch (error) {
        console.error("Error fetching bins:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchBins();
  }, []);

  // Fetch bin history when a bin is selected
  const handleSelectBin = async (binId: string) => {
    setSelectedBin(binId);
    setHistoryLoading(true);
    try {
      const rawHistoryData = await getBinHistory(binId);
      const historyData: HistoryRecord[] = rawHistoryData.map((record: Partial<HistoryRecord>) => ({
        id: record.id ?? "",
        timestamp: record.timestamp ?? new Date(),
        wasteLevel: record.wasteLevel ?? 0,
        status: record.status ?? "Unknown",
        lat: record.lat ?? 0,
        lng: record.lng ?? 0,
      }));
      const formattedHistory = historyData.map((record) => ({
        id: record.id,
        timestamp: record.timestamp && typeof record.timestamp.toDate === "function" 
          ? record.timestamp.toDate() 
          : new Date(),
        wasteLevel: record.wasteLevel ?? 0,
        status: record.status ?? "Unknown",
        lat: record.lat ?? 0,
        lng: record.lng ?? 0,
      }));
      setHistory(formattedHistory);
    } catch (error) {
      console.error("Error fetching bin history:", error);
    } finally {
      setHistoryLoading(false);
    }
  };

  // Prepare Chart Data
  const chartData = {
    labels: history.map((record) => new Date(record.timestamp).toLocaleString()),
    datasets: [
      {
        label: "Waste Level (cm)",
        data: history.map((record) => record.wasteLevel),
        fill: false,
        borderColor: "rgb(75, 192, 192)",
        tension: 0.1,
      },
    ],
  };

  // Export to CSV
  const exportToCSV = () => {
    const csvData = history.map((record) => ({
      Timestamp: new Date(record.timestamp).toLocaleString(),
      WasteLevel: record.wasteLevel,
      Status: record.status,
      Latitude: record.lat,
      Longitude: record.lng,
    }));

    const csv = Papa.unparse(csvData);
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    saveAs(blob, `bin_${selectedBin}_history.csv`);
  };

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Waste Bins</h1>

        {loading ? (
          <p>Loading bins...</p>
        ) : (
          <div className="grid gap-6">
            {bins.map((bin) => (
              <div
                key={bin.id}
                className="bg-white p-6 rounded-lg shadow-md cursor-pointer"
                onClick={() => handleSelectBin(bin.id)}
              >
                <h2 className="text-lg font-bold text-green-700">{bin.location}</h2>
                <p className="text-gray-700">Waste Level: {bin.wasteLevel} cm</p>
                <p className={`text-sm ${bin.status === "Full" ? "text-red-600" : "text-green-600"}`}>
                  Status: {bin.status}
                </p>
                <p className="text-gray-500 text-sm">📍 {bin.lat}, {bin.lng}</p>
              </div>
            ))}
          </div>
        )}

        {/* Show Bin History if a bin is selected */}
        {selectedBin && (
          <div className="mt-8">
            <h2 className="text-2xl font-bold">History of Bin {selectedBin}</h2>
            {historyLoading ? (
              <p>Loading history...</p>
            ) : history.length > 0 ? (
              <div>
                {/* Waste Level Chart */}
                <div className="bg-white p-6 rounded-lg shadow-md mt-4">
                  <h3 className="text-lg font-bold mb-2">Waste Level Over Time</h3>
                  <Line data={chartData} />
                </div>

                {/* Export Button */}
                <button
                  onClick={exportToCSV}
                  className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg"
                >
                  📥 Export to CSV
                </button>

                {/* Bin History List */}
                <div className="grid gap-6 mt-4">
                  {history.map((record) => (
                    <div key={record.id} className="bg-white p-6 rounded-lg shadow-md">
                      <p className="text-gray-700">⏱ {new Date(record.timestamp).toLocaleString()}</p>
                      <p className="text-gray-700">Waste Level: {record.wasteLevel} cm</p>
                      <p className={`text-sm ${record.status === "Full" ? "text-red-600" : "text-green-600"}`}>
                        Status: {record.status}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <p>No history available.</p>
            )}
          </div>
        )}
      </main>
    </div>
  );
};

export default BinsPage;
