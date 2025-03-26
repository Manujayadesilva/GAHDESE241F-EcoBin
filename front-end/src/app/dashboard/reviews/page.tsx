"use client";

import { useEffect, useState } from "react";
import Sidebar from "../../../components/Sidebar";
import { getRatings, getReviews } from "../../../firebase/db";

const ReviewsRatings = () => {
  const [reviews, setReviews] = useState<any[]>([]);
  const [ratings, setRatings] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      setReviews(await getReviews());
      setRatings(await getRatings());
    };
    fetchData();
  }, []);

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Ratings & Reviews</h1>

        {/* Ratings */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold mb-4">User Ratings</h2>
          <ul>
            {ratings.map((rating) => (
              <li key={rating.id} className="p-3 border-b">⭐ {rating.score}/5</li>
            ))}
          </ul>
        </div>

        {/* Reviews */}
        <div className="bg-white p-6 rounded-lg shadow-md mt-6">
          <h2 className="text-xl font-bold mb-4">User Reviews</h2>
          <ul>
            {reviews.map((review) => (
              <li key={review.id} className="p-3 border-b">{review.text}</li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
};

export default ReviewsRatings;
