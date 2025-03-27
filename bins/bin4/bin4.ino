#include <ESP8266WiFi.h>         // For WiFi connection
#include <FirebaseESP8266.h>     // Firebase library for ESP8266

// WiFi Credentials
#define WIFI_SSID "ST STAFF"
#define WIFI_PASSWORD "39gug391"

// Firebase Credentials
#define FIREBASE_HOST "https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define FIREBASE_AUTH "RDAfD0g8mGqZxS2qLHWDKQrWpRJl2hEFKgNwjuDG"

// Firebase and WiFi objects
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// Ultrasonic Sensor Pins
#define TRIG_PIN D5  // GPIO14
#define ECHO_PIN D6  // GPIO12

// GPS Coordinates and Bin Information
const float lat = 6.012655;  // Example latitude
const float lng = 80.248123; // Example longitude
const String binID = "bin4";
const String location = "Steam Yard";


void setup() {
  Serial.begin(115200);
  
  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println(" Connected!");

  // Initialize Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);

  // Ultrasonic Sensor Configuration
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
}

void loop() {
  // Measure Waste Level
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  
  // Convert time to distance (cm)
  float wasteLevel = duration * 0.034 / 2;  

  // Limit max distance to 50 cm
  if (wasteLevel > 50) {
    wasteLevel = 50;
  }

  // Determine Waste Bin Status
  String status = "Empty";
  if (wasteLevel > 40) {
    status = "Full";
  } else if (wasteLevel > 20) {
    status = "Half";
  } else {
    status = "Low";
  }

  // Send Data to Firebase
  String path = "/wasteBins/" + binID;
  Firebase.setString(firebaseData, path + "/id", binID);
  Firebase.setString(firebaseData, path + "/location", location);
  Firebase.setFloat(firebaseData, path + "/lat", lat);
  Firebase.setFloat(firebaseData, path + "/lng", lng);
  Firebase.setFloat(firebaseData, path + "/wasteLevel", wasteLevel);
  Firebase.setString(firebaseData, path + "/status", status);

  Serial.println("✅ Data Sent to Firebase!");
  Serial.println("Waste Level: " + String(wasteLevel) + " cm");
  Serial.println("Status: " + status);
  Serial.println("----------------------------");

  delay(5000); // Send data every 5 seconds
}
