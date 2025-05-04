// routes/auth_routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth_controller');

router.post('/login', authController.login);

module.exports = router;
