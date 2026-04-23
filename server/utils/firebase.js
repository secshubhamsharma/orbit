const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

let initialized = false;

function initFirebase() {
  if (initialized) return;

  const serviceAccountPath = path.resolve(
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './serviceAccountKey.json'
  );

  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Firebase service account not found at ${serviceAccountPath}. ` +
      'Download it from Firebase Console > Project Settings > Service Accounts.'
    );
  }

  const serviceAccount = require(serviceAccountPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  initialized = true;
  console.log('Firebase Admin SDK initialised');
}

function getFirestore() {
  return admin.firestore();
}

function getAuth() {
  return admin.auth();
}

function getMessaging() {
  return admin.messaging();
}

module.exports = { initFirebase, getFirestore, getAuth, getMessaging };
