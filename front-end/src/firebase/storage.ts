import { storage, db, auth } from "./firebaseConfig";
import { ref, uploadBytesResumable, getDownloadURL } from "firebase/storage";
import { doc, updateDoc } from "firebase/firestore";

export const uploadProfilePicture = async (file: File) => {
  if (!auth.currentUser) throw new Error("User not authenticated");

  const userId = auth.currentUser.uid;
  const storageRef = ref(storage, `profile_pictures/${userId}/${file.name}`);
  const uploadTask = uploadBytesResumable(storageRef, file);

  return new Promise<string>((resolve, reject) => {
    uploadTask.on(
      "state_changed",
      null,
      (error) => reject(error),
      async () => {
        const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
        const userRef = doc(db, "users", userId);
        await updateDoc(userRef, { profilePicture: downloadURL });
        resolve(downloadURL);
      }
    );
  });
};
