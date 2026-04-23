const { getAuth } = require('../utils/firebase');

/// Verifies the Firebase ID token in the Authorization header.
/// Attaches the decoded token to req.user on success.
async function authMiddleware(req, res, next) {
  const header = req.headers['authorization'];
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Missing auth token.' });
  }

  const token = header.split('Bearer ')[1];

  try {
    const decoded = await getAuth().verifyIdToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    console.warn('[AUTH] Token verification failed:', err.code);
    return res.status(401).json({ success: false, message: 'Invalid or expired token.' });
  }
}

module.exports = authMiddleware;
