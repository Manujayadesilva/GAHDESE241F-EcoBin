import { auth } from "./firebaseConfig"; 
import { 
  createUserWithEmailAndPassword, 
  signInWithEmailAndPassword, 
  signOut, 
  updateProfile,
  onAuthStateChanged
} from "firebase/auth";
import { getFirestore, doc, setDoc, getDoc } from "firebase/firestore";

const db = getFirestore();

interface SignupParams {
  name: string;
  email: string;
  password: string;
  address: string;
  phone: string;
  role?: string;
}

export const getUserRole = async (uid: string): Promise<string> => {
  const userDoc = await getDoc(doc(db, "users", uid));
  return userDoc.exists() ? userDoc.data()?.role || "user" : "user";
};

export const signup = async ({ name, email, password, address, phone, role = "user" }: SignupParams) => {
  const userCredential = await createUserWithEmailAndPassword(auth, email, password);
  const user = userCredential.user;

  await updateProfile(user, { displayName: name });

  await setDoc(doc(db, "users", user.uid), {
    name,
    email,
    address,
    phone,
    role, 
    createdAt: new Date(),
  });

  return user;
};

export const login = async (email: string, password: string) => {
  const userCredential = await signInWithEmailAndPassword(auth, email, password);
  const user = userCredential.user;

  const role = await getUserRole(user.uid);
  
  return { user, role };
};

export const logout = async () => {
  await signOut(auth);
};

export const useAuthListener = (setUser: (user: any) => void) => {
  return onAuthStateChanged(auth, async (user) => {
    if (user) {
      const role = await getUserRole(user.uid);
      setUser({ ...user, role });
    } else {
      setUser(null);
    }
  });
};

export { auth };
