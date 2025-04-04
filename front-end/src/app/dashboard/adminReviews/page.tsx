"use client";

import { useEffect, useState } from "react";
import Sidebar from "../../../components/Sidebar";
import { fetchCollection, deleteItem } from "../../../firebase/db";

const AdminReviewsRatings = () => {
  const [reviews, setReviews] = useState<any[]>([]);
  const [ratings, setRatings] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      setReviews(await fetchCollection("reviews"));
      setRatings(await fetchCollection("ratings"));
    };
    fetchData();
  }, []);

  // Delete Review or Rating
  const handleDelete = async (collection: string, id: string) => {
    await deleteItem(collection, id);
    if (collection === "reviews") setReviews(await fetchCollection("reviews"));
    else setRatings(await fetchCollection("ratings"));
  };

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Manage Ratings & Reviews</h1>

        {/* Ratings Section */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold mb-4">User Ratings</h2>
          <ul>
            {ratings.map((rating) => (
              <li key={rating.id} className="p-4 border-b flex justify-between items-center">
                <span className="text-lg">⭐ {rating.score}/5</span>
                <button
                  onClick={() => handleDelete("ratings", rating.id)}
                  className="text-red-500 hover:underline"
                >
                  ❌ Delete
                </button>
              </li>
            ))}
          </ul>
        </div>

        {/* Reviews Section */}
        <div className="bg-white p-6 rounded-lg shadow-md mt-6">
          <h2 className="text-xl font-bold mb-4">User Reviews</h2>
          <ul>
            {reviews.map((review) => (
              <li key={review.id} className="p-4 border-b flex items-center justify-between">
                <div className="flex items-center">
                  {/* User Image */}
                  {review.profilePic ? (
                    <img
                      src={review.profilePic}
                      alt="User"
                      className="w-12 h-12 rounded-full mr-4"
                    />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-gray-300 flex items-center justify-center text-lg font-bold text-gray-600 mr-4">
                      {review.name[0].toUpperCase()}
                    </div>
                  )}
                  <div>
                    <p className="font-bold">{review.name}</p>
                    <p className="text-gray-500 text-sm">{new Date(review.date).toDateString()}</p>
                    <p className="mt-1">{review.text}</p>
                    <div className="text-yellow-500">{"⭐".repeat(review.rating)}</div>
                  </div>
                </div>
                <button
                  onClick={() => handleDelete("reviews", review.id)}
                  className="text-red-500 hover:underline"
                >
                  ❌ Delete
                </button>
              </li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
};

export default AdminReviewsRatings;
