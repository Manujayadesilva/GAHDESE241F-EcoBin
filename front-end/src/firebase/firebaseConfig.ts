import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage, ref, uploadBytesResumable, getDownloadURL } from "firebase/storage";

// Your Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyBVRhl5af7yx04_MtYuN5ejYgSjbLwDdVU",
  authDomain: "smart-waste-management-3041a.firebaseapp.com",
  databaseURL: "https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "smart-waste-management-3041a",
  storageBucket: "smart-waste-management-3041a.firebasestorage.app",
  messagingSenderId: "378788627505",
  appId: "1:378788627505:web:bc05cb057b77fc74e50110"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

export { auth, db, firebaseConfig, app , storage};
