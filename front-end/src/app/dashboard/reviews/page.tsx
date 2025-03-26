"use client";

import { useEffect, useState } from "react";
import { getRatings, getReviews, addReview } from "../../../firebase/db";
import { useAuth } from "../../../firebase/authContext"; // Ensure auth context is implemented
import Sidebar from "../../../components/Sidebar";

const ReviewsRatings = () => {
  const { user } = useAuth(); // Fetch logged-in user
  const [reviews, setReviews] = useState<any[]>([]);
  const [ratings, setRatings] = useState<any[]>([]);
  const [newReview, setNewReview] = useState("");
  const [newRating, setNewRating] = useState(5);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      setReviews(await getReviews());
      setRatings(await getRatings());
    };
    fetchData();
  }, []);

  const handleReviewSubmit = async () => {
    if (!newReview.trim()) return;
    setLoading(true);

    if (!user) {
      console.error("User is not logged in.");
      return;
    }

    await addReview({
      userId: user.uid,
      name: user.displayName || "Anonymous",
      profilePic: user.photoURL || "",
      rating: newRating,
      text: newReview,
      date: new Date().toISOString(),
    });

    setNewReview("");
    setNewRating(5);
    setLoading(false);
    setReviews(await getReviews());
  };

  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 p-8 w-full bg-gray-100 min-h-screen">
        <h1 className="text-3xl font-bold mb-4">Rate & Reviews</h1>

        {/* Review Submission */}
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-bold mb-4">Submit Your Review</h2>
          <textarea
            className="w-full border rounded-lg p-3"
            placeholder="Share your experience..."
            value={newReview}
            onChange={(e) => setNewReview(e.target.value)}
          />
          <div className="flex items-center mt-3">
            <label className="mr-2">Rating:</label>
            <select
              value={newRating}
              onChange={(e) => setNewRating(Number(e.target.value))}
              className="border p-2 rounded-lg"
            >
              {[1, 2, 3, 4, 5].map((num) => (
                <option key={num} value={num}>
                  {num} ⭐
                </option>
              ))}
            </select>
          </div>
          <button
            onClick={handleReviewSubmit}
            className="bg-green-600 text-white px-4 py-2 mt-4 rounded-lg"
            disabled={loading}
          >
            {loading ? "Submitting..." : "Submit Review"}
          </button>
        </div>

        {/* User Reviews */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold mb-4">Customer Reviews</h2>
          <ul>
            {reviews.map((review) => (
              <li key={review.id} className="p-4 border-b">
                <div className="flex items-center">
                  {review.profilePic ? (
                    <img
                      src={review.profilePic}
                      alt="User"
                      className="w-10 h-10 rounded-full mr-3"
                    />
                  ) : (
                    <div className="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center mr-3">
                      {review.name[0].toUpperCase()}
                    </div>
                  )}
                  <div>
                    <p className="font-bold">{review.name}</p>
                    <p className="text-gray-500 text-sm">{new Date(review.date).toDateString()}</p>
                  </div>
                </div>
                <div className="mt-2">
                  {"⭐".repeat(review.rating)}
                </div>
                <p className="mt-2">{review.text}</p>
                <div className="flex items-center mt-3 text-gray-600">
                  <button className="mr-4 flex items-center hover:text-green-600">
                    👍 Helpful
                  </button>
                  <button className="mr-4 flex items-center hover:text-red-600">
                    🚩 Report
                  </button>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
};

export default ReviewsRatings;
