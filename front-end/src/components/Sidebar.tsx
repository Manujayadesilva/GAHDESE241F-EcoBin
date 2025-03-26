"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Home, User, Trash, Settings, Users, Calendar, Star } from "lucide-react";
import { useEffect, useState } from "react";
import { getCurrentUser } from "@/firebase/db";

const Sidebar = () => {
  const pathname = usePathname() || "";
  const [userRole, setUserRole] = useState<string | null>(null);

  useEffect(() => {
    const fetchUserRole = async () => {
      const user = await getCurrentUser();
      if (user) setUserRole(user.role);
    };
    fetchUserRole();
  }, []);

  const navItems = [
    { href: "/dashboard", label: "Dashboard", icon: <Home size={20} /> },
    { href: "/dashboard/profile", label: "Profile", icon: <User size={20} /> },
    { href: "/dashboard/bins", label: "Bins", icon: <Trash size={20} /> },
    { href: "/dashboard/events", label: "Events & Updates", icon: <Calendar size={20} /> },
    { href: "/dashboard/reviews", label: "Ratings & Reviews", icon: <Star size={20} /> },
    { href: "/dashboard/settings", label: "Settings", icon: <Settings size={20} /> },
  ];
  
  if (userRole === "admin") {
    navItems.push(
      { href: "/dashboard/users", label: "Manage Users", icon: <Users size={20} /> },
      { href: "/dashboard/adminEvents", label: "Manage Events & Updates", icon: <Calendar size={20} /> },
      { href: "/dashboard/adminReviews", label: "Manage Ratings & Reviews", icon: <Star size={20} /> },
    );
  }

  return (
    <aside className="bg-gray-900 text-white w-64 h-screen p-6 fixed top-0 left-0">
      <h2 className="text-2xl font-bold mb-6">Waste Management</h2>
      <nav>
        <ul className="flex flex-col gap-4">
          {navItems.map((item) => (
            <li key={item.href}>
              <Link
                href={item.href}
                className={`flex items-center gap-3 p-3 rounded-md transition-all ${
                  pathname === item.href ? "bg-blue-500" : "hover:bg-gray-700"
                }`}
              >
                {item.icon}
                <span>{item.label}</span>
              </Link>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  );
};

export default Sidebar;
