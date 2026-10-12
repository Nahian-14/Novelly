const express = require('express');
const User = require('../models/User');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

function serialize(user) {
  return {
    uid: user.firebaseUid,
    name: user.name,
    email: user.email,
    role: user.role,
  };
}

// POST /api/users/sync
// Called right after a successful Firebase sign-in or registration.
// Creates the MongoDB profile the first time a given Firebase uid is seen,
// and simply returns the existing profile on every later call (the `role`
// sent in the body is only used the first time, when the profile is
// created — it's ignored for an existing user, since someone shouldn't be
// able to silently change their own role just by signing in again).
router.post('/sync', requireAuth, async (req, res) => {
  const { uid, email: tokenEmail } = req.firebaseUser;
  const { name, email, role } = req.body || {};

  try {
    let user = await User.findOne({ firebaseUid: uid });

    if (!user) {
      user = await User.create({
        firebaseUid: uid,
        name: name || '',
        email: email || tokenEmail || '',
        role: role || 'Writer',
      });
    }

    res.json(serialize(user));
  } catch (err) {
    console.error('Error syncing user:', err);
    res.status(500).json({ error: 'Could not sync user profile.' });
  }
});

// GET /api/users/me
// Returns the signed-in user's MongoDB profile. 404 if /sync was never
// called for this uid (shouldn't normally happen, since the app calls
// /sync right after sign-in/registration).
router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.firebaseUser.uid });
    if (!user) {
      return res.status(404).json({ error: 'No profile found for this user yet.' });
    }
    res.json(serialize(user));
  } catch (err) {
    console.error('Error fetching user:', err);
    res.status(500).json({ error: 'Could not fetch user profile.' });
  }
});

module.exports = router;
