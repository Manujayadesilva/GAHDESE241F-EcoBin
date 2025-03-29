import { getDatabase, ref, onValue } from "firebase/database";
import { app } from "./firebaseConfig"; // Firebase initialization
import { db } from "./firebaseConfig";
import { collection, doc, getDocs, updateDoc, deleteDoc, getDoc, addDoc, arrayUnion, arrayRemove, query, where, orderBy  } from "firebase/firestore";
import { auth } from "./firebaseConfig";
import { User } from "../types/User";



export const fetchBinsData = (setBins: (data: any) => void) => {
  const db = getDatabase(app);
  const binsRef = ref(db, "wasteBins");

  const unsubscribe = onValue(binsRef, (snapshot) => {
    setBins(snapshot.exists() ? snapshot.val() : null);
  });

  return () => unsubscribe(); // Unsubscribes when component unmounts
};


// 📌 Fetch the current user's data
export const getCurrentUser = async (): Promise<User | null> => {
  const user = auth.currentUser;
  if (!user) return null;

  const userDoc = await getDoc(doc(db, "users", user.uid));

  if (!userDoc.exists()) return null;

  // Ensure all expected fields exist
  const data = userDoc.data();
  return {
    id: user.uid,
    name: data.name || "",
    email: data.email || "",
    phone: data.phone || "",
    address: data.address || "",
    profilePicture: data.profilePicture || "",
    role: data.role || "user",

  };
};

// 📌 Update user profile data
export const updateUserProfile = async (userId: string, updatedData: any) => {
  const userRef = doc(db, "users", userId);
  await updateDoc(userRef, updatedData);
};

// 📌 Fetch all users
export const getAllUsers = async () => {
  const usersRef = collection(db, "users");
  const snapshot = await getDocs(usersRef);
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

export const getUserRole = async (userId: string) => {
  const userDoc = await getDoc(doc(db, "users", userId));
  return userDoc.exists() ? userDoc.data()?.role || "user" : "user";
};

// 📌 Update user role
export const updateUserRole = async (userId: string, newRole: string) => {
  const userRef = doc(db, "users", userId);
  await updateDoc(userRef, { role: newRole });
};

// 📌 Delete user
export const deleteUser = async (userId: string) => {
  const userRef = doc(db, "users", userId);
  await deleteDoc(userRef);
};

// 📌 Fetch Events
export const getEvents = async () => {
  const snapshot = await getDocs(collection(db, "events"));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

// 📌 Fetch Updates
export const getUpdates = async () => {
  const snapshot = await getDocs(collection(db, "updates"));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

// 📌 Fetch Ratings
export const getRatings = async () => {
  const snapshot = await getDocs(collection(db, "ratings"));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

// 📌 Fetch Reviews
export const getReviews = async () => {
  const snapshot = await getDocs(collection(db, "reviews"));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

// 📌 Add an Event
export const addEvent = async (eventData: any) => {
  await addDoc(collection(db, "events"), eventData);
};

// 📌 Add an Update
export const addUpdate = async (updateData: any) => {
  await addDoc(collection(db, "updates"), updateData);
};

// 📌 Add a Rating
export const addRating = async (ratingData: any) => {
  await addDoc(collection(db, "ratings"), ratingData);
};

// 📌 Add a Review
export const addReview = async (reviewData: any) => {
  await addDoc(collection(db, "reviews"), reviewData);
};



// 📌 Fetch Data (Events, Updates, Ratings, Reviews)
export const fetchCollection = async (collectionName: string) => {
  const snapshot = await getDocs(collection(db, collectionName));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

// 📌 Add an Item (Event, Update, Rating, Review)
export const addItem = async (collectionName: string, data: any) => {
  await addDoc(collection(db, collectionName), data);
};

// 📌 Delete an Item
export const deleteItem = async (collectionName: string, id: string) => {
  await deleteDoc(doc(db, collectionName, id));
};


export const deleteEvent = async (eventId: string) => {
  await deleteDoc(doc(db, "events", eventId));
};

// ✅ Register for an event (Add user to participants)
export const registerForEvent = async (eventId: string, userId: string) => {
  const eventRef = doc(db, "events", eventId);
  try {
    await updateDoc(eventRef, {
      participants: arrayUnion(userId),
    });
  } catch (error) {
    console.error("Error registering for event:", error);
  }
};

// ✅ Cancel event registration (Remove user from participants)
export const cancelRegistration = async (eventId: string, userId: string) => {
  const eventRef = doc(db, "events", eventId);
  try {
    await updateDoc(eventRef, {
      participants: arrayRemove(userId),
    });
  } catch (error) {
    console.error("Error canceling registration:", error);
  }
};

// Fetch all bins
export const getBins = async () => {
  const snapshot = await getDocs(collection(db, "bins"));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

// Fetch bin history for a specific bin
export const fetchBinHistory = async (binId: string) => {
  const historyRef = collection(db, `bins/${binId}/history`);
  const querySnapshot = await getDocs(historyRef);
  return querySnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};

export const getBinHistory = async (binId: string) => {
  const historyRef = collection(db, `bins/${binId}/history`);
  const sortedQuery = query(historyRef, orderBy("timestamp", "desc"));
  const querySnapshot = await getDocs(sortedQuery);
  return querySnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
};


export type { User };

