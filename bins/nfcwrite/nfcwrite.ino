#include <SPI.h>
#include <MFRC522.h>

#define SS_PIN D4
#define RST_PIN D3

MFRC522 mfrc522(SS_PIN, RST_PIN); 

// Define the Firebase UID to write (28 characters)
const char userID[] = "asdfghjjkklmnbv"; // Exact 28 chars

// Default MIFARE key
MFRC522::MIFARE_Key key;

void setup() {
    Serial.begin(115200);
    SPI.begin();
    mfrc522.PCD_Init();

    // Initialize the key with default value 0xFF
    for (byte i = 0; i < 6; i++) {
        key.keyByte[i] = 0xFF;
    }

    Serial.println("Scan an NFC card to write the User ID...");
}

void loop() {
    // Wait for an NFC card
    if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) {
        return;
    }

    Serial.println("Card detected! Writing User ID...");

    // Write the User ID to NFC card (manually defining blocks)
    if (writeUserID()) {
        Serial.println("✅ User ID written successfully!");

        // Read and verify the written UID
        String readUID = readUserID();
        Serial.print("🔍 Read from card: ");
        Serial.println(readUID);
    } else {
        Serial.println("❌ Failed to write User ID!");
    }

    delay(2000);
}

// Function to write User ID to the NFC card
bool writeUserID() {
    byte buffer1[16]; // Block 4 (First 16 bytes)
    byte buffer2[16]; // Block 5 (Remaining 12 bytes + padding)

    // Manually assign first 16 bytes
    for (int i = 0; i < 16; i++) {
        buffer1[i] = userID[i];
    }

    // Manually assign last 12 bytes and pad remaining bytes with 0x00
    for (int i = 0; i < 12; i++) {
        buffer2[i] = userID[16 + i];
    }
    for (int i = 12; i < 16; i++) {
        buffer2[i] = 0x00; // Padding
    }

    // Authenticate and write data to block 4
    if (!writeBlock(4, buffer1)) return false;
    
    // Authenticate and write data to block 5
    if (!writeBlock(5, buffer2)) return false;

    return true;
}

// Function to read User ID from NFC card
String readUserID() {
    byte buffer1[16]; // Block 4
    byte buffer2[16]; // Block 5
    String storedUID = "";

    // Read Block 4
    if (readBlock(4, buffer1)) {
        for (int i = 0; i < 16; i++) {
            storedUID += (char)buffer1[i];
        }
    }

    // Read Block 5 (Only first 12 bytes)
    if (readBlock(5, buffer2)) {
        for (int i = 0; i < 12; i++) {
            storedUID += (char)buffer2[i];
        }
    }

    storedUID.trim(); // Remove extra spaces/null characters
    return storedUID;
}

// Function to authenticate and write to an NFC block
bool writeBlock(byte block, byte data[]) {
    MFRC522::StatusCode status;

    // Authenticate the block
    status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, block, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK) {
        Serial.print("Authentication failed at block ");
        Serial.println(block);
        return false;
    }

    // Write the data
    status = mfrc522.MIFARE_Write(block, data, 16);
    if (status != MFRC522::STATUS_OK) {
        Serial.print("Write failed at block ");
        Serial.println(block);
        return false;
    }

    Serial.print("Write successful at block ");
    Serial.println(block);
    return true;
}

// Function to authenticate and read an NFC block
bool readBlock(byte block, byte buffer[]) {
    MFRC522::StatusCode status;
    byte bufferSize = 18; // Correct buffer size

    // Authenticate the block
    status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, block, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK) {
        Serial.print("Authentication failed at block ");
        Serial.println(block);
        return false;
    }

    // Read the block
    status = mfrc522.MIFARE_Read(block, buffer, &bufferSize);
    if (status != MFRC522::STATUS_OK) {
        Serial.print("Read failed at block ");
        Serial.println(block);
        return false;
    }

    return true;
}
