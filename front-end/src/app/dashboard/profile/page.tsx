"use client";

import { useEffect, useState } from "react";
import { getCurrentUser, updateUserProfile, User } from "@/firebase/db";
import { uploadProfilePicture } from "@/firebase/storage";
import Sidebar from "@/components/Sidebar";

const Profile = () => {
  const [user, setUser] = useState<User | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    address: "",
  });
  const [profileImage, setProfileImage] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  // Fetch user data when the component loads
  useEffect(() => {
    const fetchUserData = async () => {
      const userData = await getCurrentUser();
      if (userData) {
        setUser(userData);
        setFormData({
          name: userData.name || "",
          email: userData.email || "",
          phone: userData.phone || "",
          address: userData.address || "",
        });
        setProfileImage(userData.profilePicture || null);
      }
    };

    fetchUserData();
  }, []);

  // Handle input change
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // Handle profile update
  const handleUpdate = async () => {
    if (user) {
      await updateUserProfile(user.id, { ...formData, profilePicture: profileImage });
      alert("Profile updated successfully!");
    } else {
      alert("User data is not available.");
    }
  };

  // Handle file selection
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setFile(e.target.files[0]);
    }
  };

  // Handle profile picture upload
  const handleUpload = async () => {
    if (!file || !user) return;
    setUploading(true);
    try {
      const imageUrl = await uploadProfilePicture(file);
      setProfileImage(imageUrl);
      await updateUserProfile(user.id, { profilePicture: imageUrl });
      alert("Profile picture updated!");
    } catch (error) {
      alert("Upload failed!");
    }
    setUploading(false);
  };

  if (!user) return <p className="text-center mt-10">Loading...</p>;

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen flex justify-center">
        <div className="bg-white p-6 rounded-lg shadow-md w-full max-w-lg">
          <h1 className="text-3xl font-bold mb-6 text-center">User Profile</h1>

          {/* Profile Picture Section */}
          <div className="flex flex-col items-center mb-6">
            <div className="relative">
              <img
                src={profileImage || "/default-profile.png"}
                alt="Profile"
                className="w-32 h-32 rounded-full border-4 border-gray-300 object-cover"
              />
            </div>

            <input type="file" accept="image/*" onChange={handleFileChange} className="mt-4" />
            <button
              onClick={handleUpload}
              disabled={uploading}
              className="bg-green-500 text-white px-4 py-2 rounded mt-2 hover:bg-green-600 disabled:opacity-50"
            >
              {uploading ? "Uploading..." : "Upload New Picture"}
            </button>
          </div>

          {/* Personal Information Section */}
          <h2 className="text-xl font-bold mb-4">Personal Information</h2>

          <div className="space-y-4">
            <div>
              <label className="block text-gray-700">Name:</label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                className="w-full p-2 border rounded"
              />
            </div>

            <div>
              <label className="block text-gray-700">Email:</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                readOnly
                className="w-full p-2 border rounded bg-gray-100"
              />
            </div>

            <div>
              <label className="block text-gray-700">Phone:</label>
              <input
                type="text"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                className="w-full p-2 border rounded"
              />
            </div>

            <div>
              <label className="block text-gray-700">Address:</label>
              <input
                type="text"
                name="address"
                value={formData.address}
                onChange={handleChange}
                className="w-full p-2 border rounded"
              />
            </div>

            <button
              onClick={handleUpdate}
              className="bg-blue-500 text-white p-2 rounded w-full hover:bg-blue-600"
            >
              Update Profile
            </button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Profile;
