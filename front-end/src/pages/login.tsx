"use client";
import { useState } from "react";
import { login } from "../firebase/auth";
import { useRouter } from "next/navigation";
import Image from "next/image";
import "../app/globals.css";
import { useAuth } from "../firebase/authContext"; // Adjust path based on your project

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();

  const handleLogin = async (event: React.FormEvent) => {
    event.preventDefault();
    try {
      const { user, role } = await login(email, password);

      // Redirect based on role
      if (role === "admin") {
        router.replace("/admin/dashboard"); // Redirect to Admin Dashboard
      } 
      if (role == "user") {
        router.replace("/dashboard"); // Redirect to User Dashboard
      }
    } catch (err: any) {
      setError(err.message);
    }
  };
  

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
        <div className="flex justify-center mb-4">
          <Image src="/logo.webp" alt="Logo" width={40} height={40} />
        </div>

        <h2 className="text-2xl font-bold text-center mb-6">Sign in to your account</h2>

        {error && <p className="text-red-500 text-center">{error}</p>}

        <form onSubmit={handleLogin}>
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700">Email Address</label>
            <input
              type="email"
              placeholder="Enter your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
              autoComplete="username"
            />
          </div>

          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700">Password</label>
            <input
              type="password"
              placeholder="Enter your password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
              autoComplete="current-password"
            />
          </div>

          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 transition"
          >
            Login
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
