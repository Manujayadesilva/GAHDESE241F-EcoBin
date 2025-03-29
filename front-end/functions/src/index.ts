/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.addBinData = functions.https.onRequest(async (req: { body: { binID: any; wasteLevel: any; status: any; lat: any; lng: any; }; }, res: { status: (arg0: number) => { (): any; new(): any; send: { (arg0: string): any; new(): any; }; }; }) => {
  try {
    const { binID, wasteLevel, status, lat, lng } = req.body;

    if (!binID) {
      return res.status(400).send("Missing binID");
    }

    const timestamp = new Date().toISOString();

    // Save to Firestore
    await admin.firestore().collection("bins").doc(binID).set({
      id: binID,
      lat,
      lng,
      wasteLevel,
      status,
      timestamp,
    });

    // Save to history
    await admin.firestore().collection(`bins/${binID}/history`).add({
      timestamp,
      wasteLevel,
      status,
      lat,
      lng,
    });

    return res.status(200).send("Data added successfully!");
  } catch (error) {
    console.error(error);
    return res.status(500).send("Error saving data.");
  }
});
