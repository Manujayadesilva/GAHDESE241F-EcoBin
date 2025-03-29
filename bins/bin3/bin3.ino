#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

// WiFi Credentials
#define WIFI_SSID "Dialog 4G 399"
#define WIFI_PASSWORD "31b06c07"

// Firebase Credentials
#define FIREBASE_HOST "https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define FIREBASE_AUTH "RDAfD0g8mGqZxS2qLHWDKQrWpRJl2hEFKgNwjuDG"

// Firestore API
#define FIRESTORE_PROJECT_ID "smart-waste-management-3041a"
#define FIRESTORE_URL "https://firestore.googleapis.com/v1/projects/" FIRESTORE_PROJECT_ID "/databases/(default)/documents/bins/bin2/history"

// Firebase Objects
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// Sensor Pins
#define TRIG_PIN D5  
#define ECHO_PIN D6  

// Bin Details
const float lat = 6.036913;  
const float lng = 80.223790; 
const String binID = "bin3";
const String location = "NIBM Galle";

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

  // Configure Sensor Pins
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
}

void loop() {
  float wasteLevel = getWasteLevel();
  String status = getWasteStatus(wasteLevel);
  String timestamp = getFormattedTimestamp();  

  // Update Realtime Database (Live Updates)
  String dbPath = "/wasteBins/" + binID;
  Firebase.setString(firebaseData, dbPath + "/id", binID);
  Firebase.setString(firebaseData, dbPath + "/location", location);
  Firebase.setFloat(firebaseData, dbPath + "/lat", lat);
  Firebase.setFloat(firebaseData, dbPath + "/lng", lng);
  Firebase.setFloat(firebaseData, dbPath + "/wasteLevel", wasteLevel);
  Firebase.setString(firebaseData, dbPath + "/status", status);

  Serial.println("✅ Realtime Database Updated!");

  // Send data to Firestore
  sendToFirestore(timestamp, wasteLevel, status);

  Serial.println("----------------------------");
  
  delay(5000);
}

// Measure Waste Level
float getWasteLevel() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  float distance = duration * 0.034 / 2;  
  return (distance > 50) ? 50 : distance;
}

// Determine Waste Bin Status
String getWasteStatus(float level) {
  if (level > 40) return "Full";
  if (level > 20) return "Half";
  return "Low";
}

// Generate ISO Timestamp
String getFormattedTimestamp() {
  time_t now = millis() / 1000;  
  struct tm timeStruct;
  gmtime_r(&now, &timeStruct);
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", &timeStruct);
  return String(buffer);
}

// Send Data to Firestore
void sendToFirestore(String timestamp, float wasteLevel, String status) {
  WiFiClientSecure client;
  client.setInsecure();  

  Serial.print("Connecting to Firestore... ");
  if (!client.connect("firestore.googleapis.com", 443)) {
    Serial.println("❌ Connection Failed!");
    return;
  }
  Serial.println("✅ Connected!");

  // Firestore API Endpoint
  String url = String("/v1/projects/") + FIRESTORE_PROJECT_ID +
             "/databases/(default)/documents/bins/" + binID + "/history?access_token=" + FIREBASE_AUTH;

  // JSON Payload
  String jsonPayload = "{"
    "\"fields\": {"
    "\"timestamp\": {\"timestampValue\": \"" + timestamp + "\"},"
    "\"wasteLevel\": {\"doubleValue\": " + String(wasteLevel) + "},"
    "\"status\": {\"stringValue\": \"" + status + "\"},"
    "\"lat\": {\"doubleValue\": " + String(lat) + "},"
    "\"lng\": {\"doubleValue\": " + String(lng) + "},"
    "\"location\": {\"stringValue\": \"" + location + "\"}"
    "}"
  "}";

  // Send HTTP Request
  client.print(String("POST ") + url + " HTTP/1.1\r\n" +
               "Host: firestore.googleapis.com\r\n" +
               "User-Agent: ESP8266\r\n" +
               "Content-Type: application/json\r\n" +
               "Content-Length: " + String(jsonPayload.length()) + "\r\n" +
               "Connection: close\r\n\r\n" +
               jsonPayload);

  // Read Firestore Response
  while (client.connected()) {
    String line = client.readStringUntil('\n');
    if (line == "\r") break;
  }

  Serial.println("✅ Firestore Data Stored!");
  while (client.available()) {
    Serial.println(client.readString());
  }
}
