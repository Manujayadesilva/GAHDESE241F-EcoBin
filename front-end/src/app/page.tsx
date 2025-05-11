import Header from "../components/Header";
import Footer from "../components/Footer";
import Link from "next/link";

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen">
      <Header />

      {/* Hero Section */}
      <main className="flex flex-col items-center justify-center flex-grow bg-gradient-to-br from-green-100 to-white p-8">
        <h1 className="text-5xl font-extrabold text-center text-green-800 mb-4">
          Smart Waste Management System
        </h1>
        <p className="text-xl text-gray-700 text-center max-w-2xl mb-6">
          Real-time waste monitoring, smart bin access with NFC, and location tracking for a cleaner, smarter city.
        </p>

        <div className="flex flex-col md:flex-row gap-4">
          <Link
            href="/signup"
            className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-semibold"
          >
            Get Started
          </Link>
          <Link
            href="/login"
            className="bg-gray-700 hover:bg-gray-800 text-white px-6 py-3 rounded-lg font-semibold"
          >
            Login
          </Link>
        </div>
      </main>

      {/* Features Section */}
      <section className="py-16 bg-white text-center px-8">
        <h2 className="text-3xl font-bold text-gray-800 mb-8">Key Features</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
          <div className="p-6 bg-gray-50 rounded shadow hover:shadow-md transition">
            <h3 className="text-xl font-semibold mb-2">Real-Time Waste Levels</h3>
            <p className="text-gray-600">Monitor bin fill levels and get alerts before overflow.</p>
          </div>
          <div className="p-6 bg-gray-50 rounded shadow hover:shadow-md transition">
            <h3 className="text-xl font-semibold mb-2">Smart Bin Access</h3>
            <p className="text-gray-600">Secure bins using NFC card access linked to user profiles.</p>
          </div>
          <div className="p-6 bg-gray-50 rounded shadow hover:shadow-md transition">
            <h3 className="text-xl font-semibold mb-2">GPS Tracking</h3>
            <p className="text-gray-600">Easily locate bins on a live map across the city.</p>
          </div>
        </div>
      </section>

      {/* Call to Action */}
      <section className="bg-green-600 text-white py-12 px-6 text-center">
        <h2 className="text-2xl font-bold mb-4">Start managing waste the smart way</h2>
        <Link
          href="/signup"
          className="bg-white text-green-700 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100"
        >
          Create Your Account
        </Link>
      </section>

      <Footer />
    </div>
  );
}
// Removed duplicate export default statement
