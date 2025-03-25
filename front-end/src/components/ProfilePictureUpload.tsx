"use client";

import { useState } from "react";
import { uploadProfilePicture } from "../firebase/storage";

const ProfilePictureUpload = () => {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [imageURL, setImageURL] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files) {
      setFile(event.target.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) return;

    setUploading(true);
    setError(null);

    try {
      const url = await uploadProfilePicture(file);
      setImageURL(url);
    } catch (err: any) {
      setError(err.message);
    }

    setUploading(false);
  };

  return (
    <div className="p-6 bg-white rounded-lg shadow">
      <h2 className="text-xl font-bold mb-4">Upload Profile Picture</h2>
      <input type="file" accept="image/*" onChange={handleFileChange} className="mb-4" />
      <button
        onClick={handleUpload}
        disabled={uploading}
        className="bg-blue-500 text-white px-4 py-2 rounded disabled:opacity-50"
      >
        {uploading ? "Uploading..." : "Upload"}
      </button>

      {error && <p className="text-red-500 mt-2">{error}</p>}

      {imageURL && (
        <div className="mt-4">
          <p className="text-gray-600">Uploaded Image:</p>
          <img src={imageURL} alt="Profile" className="w-32 h-32 rounded-full mt-2" />
        </div>
      )}
    </div>
  );
};

export default ProfilePictureUpload;
