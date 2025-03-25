"use client";
import { GoogleMap, Marker, InfoWindow, useJsApiLoader } from "@react-google-maps/api";
import { useEffect, useState } from "react";
import { fetchBinsData } from "../firebase/db";

const containerStyle = {
  width: "100%",
  height: "300px",
};

const defaultCenter = {
  lat: 6.0174, // Default location (Colombo)
  lng: 80.2489,
};



const GoogleMapComponent = () => {
  const { isLoaded } = useJsApiLoader({
    googleMapsApiKey: process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY!,
  });

  const [bins, setBins] = useState<any>(null);
  const [selectedBin, setSelectedBin] = useState<any>(null);
  const [currentLocation, setCurrentLocation] = useState(defaultCenter);

  useEffect(() => {
    fetchBinsData(setBins);

    // Get user's current location
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setCurrentLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          });
        },
        (error) => {
          console.error("Error getting location:", error);
        }
      );
    }
  }, []);

  if (!isLoaded) return <p>Loading Map...</p>;

  return (
    <GoogleMap mapContainerStyle={containerStyle} center={currentLocation} zoom={13}>
      {/* Display all bin locations */}
      {bins &&
      Object.entries(bins).map(([key, bin]: any) => (
        <Marker
        key={key}
        position={{ lat: bin.lat, lng: bin.lng }}
        label={bin.status === "Full" ? "🔴" : "🟢"}
        onClick={() => setSelectedBin(bin)} // Open Info Window on Click
        />
      ))}

      {/* Show Info Window when a bin is clicked */}
      {selectedBin && (
      <InfoWindow
        position={{ lat: selectedBin.lat, lng: selectedBin.lng }}
        onCloseClick={() => setSelectedBin(null)}
      >
        <div>
        <h2 className="font-bold">Bin Information</h2>
        <p>Status: {selectedBin.status}</p>
        <p>Location: {selectedBin.lat}, {selectedBin.lng}</p>
        </div>
      </InfoWindow>
      )}

      {/* Show User's Current Location */}
      <Marker
      position={currentLocation}
      icon={{
        path: google.maps.SymbolPath.CIRCLE,
        scale: 8,
        fillColor: "deepskyblue",
        fillOpacity: 1,
        strokeWeight: 0,
      }}
      />
    </GoogleMap>
  );
};

export default GoogleMapComponent;
