const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

// Two ways to supply Firebase Admin credentials (see .env.example):
//
// Option A: a serviceAccountKey.json file dropped next to this project
//           (simplest for local development).
// Option B: FIREBASE_PROJECT_ID / FIREBASE_CLIENT_EMAIL / FIREBASE_PRIVATE_KEY
//           env vars (better for deploying to a host like Render/Railway,
//           where you usually can't just drop a JSON file in).
function loadCredential() {
  const keyFilePath = path.join(__dirname, '..', '..', 'serviceAccountKey.json');

  if (fs.existsSync(keyFilePath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(keyFilePath, 'utf8'));
    return admin.credential.cert(serviceAccount);
  }

  const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } =
    process.env;

  if (FIREBASE_PROJECT_ID && FIREBASE_CLIENT_EMAIL && FIREBASE_PRIVATE_KEY) {
    return admin.credential.cert({
      projectId: FIREBASE_PROJECT_ID,
      clientEmail: FIREBASE_CLIENT_EMAIL,
      // .env files can't hold real newlines in a value, so the private key
      // is stored with literal "\n" and we turn those back into real ones.
      privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    });
  }

  throw new Error(
    'No Firebase Admin credentials found. Either drop a ' +
      'serviceAccountKey.json file in the backend/ folder, or set ' +
      'FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY ' +
      'in backend/.env. See .env.example for details.'
  );
}

if (!admin.apps.length) {
  admin.initializeApp({ credential: loadCredential() });
}

module.exports = admin;
