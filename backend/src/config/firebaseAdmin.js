const { initializeApp, getApps, cert } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const path = require("path");

const serviceAccount = require(
    path.join(
        __dirname,
        "../../firebase-service-account.json"
    )
);

const firebaseApp =
    getApps().length === 0
        ? initializeApp({
            credential: cert(serviceAccount),
        })
        : getApps()[0];

const messaging = getMessaging(firebaseApp);

module.exports = {
    firebaseApp,
    messaging,
};