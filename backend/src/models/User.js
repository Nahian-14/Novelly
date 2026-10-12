const mongoose = require('mongoose');

// The MongoDB-backed profile for a user. Firebase owns the "identity" part
// (uid, email, password) — this document is "the rest": role and anything
// else the app needs later (bio, royaltyInfo, portfolio, etc.).
const userSchema = new mongoose.Schema(
  {
    // Firebase's uid — this is how we match a verified request back to a
    // MongoDB document. Unique and indexed since every lookup is by this.
    firebaseUid: { type: String, required: true, unique: true, index: true },
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, trim: true, lowercase: true },
    role: {
      type: String,
      required: true,
      enum: ['Writer', 'Publisher', 'Cover Artist', 'Writer and Publisher'],
      default: 'Writer',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
