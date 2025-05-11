"use client";
import Link from "next/link";
import Image from "next/image";

const Header = () => {
  return (
    <header className="bg-white shadow-md px-6 py-4 flex items-center justify-between w-full">
      {/* Left Section: Logo */}
      <div className="flex items-center">
        <Image src="/logo.webp" alt="Logo" width={50} height={30} />
      </div>

      {/* Navigation Links */}
      <nav className="flex-grow">
        <ul className="flex justify-center gap-8 text-gray-900 font-medium">
          <li>
            <Link href="/" className="hover:text-gray-500">
              Soulutions
            </Link>
          </li>
          <li>
            <Link href="/features" className="hover:text-gray-500">
              Use Cases
            </Link>
          </li>
          
          <li>
            <Link href="/marketplace" className="hover:text-gray-500">
              Company
            </Link>
          </li>
          <li>
            <Link href="/company" className="hover:text-gray-500">
              Contact Us
            </Link>
          </li>
        </ul>
      </nav>

      {/* Right Section: Login & Sign-up Buttons */}
      <div className="flex items-center gap-4">
        <Link href="/login" className="text-gray-900 hover:text-gray-500">
          Log in
        </Link>
        <Link
          href="/signup"
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
        >
          Sign up
        </Link>
      </div>
    </header>
  );
};

export default Header;
