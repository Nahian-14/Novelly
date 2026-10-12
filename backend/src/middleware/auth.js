const admin = require('../config/firebaseAdmin');

// Express middleware that verifies the Firebase ID token sent by the
// Flutter app (in the "Authorization: Bearer <token>" header) before
// letting a request touch MongoDB. On success it attaches the decoded
// token to req.firebaseUser (so later handlers know req.firebaseUser.uid,
// .email, etc.); on failure it stops the request with 401.
async function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Missing or malformed Authorization header.' });
  }

  try {
    req.firebaseUser = await admin.auth().verifyIdToken(token);
    next();
  } catch (err) {
    console.error('Failed to verify Firebase ID token:', err.message);
    res.status(401).json({ error: 'Invalid or expired token.' });
  }
}

module.exports = { requireAuth };
