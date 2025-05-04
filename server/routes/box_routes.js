// routes/box_routes.js
const express = require('express');
const router = express.Router();
const boxController = require('../controllers/box_controller');

router.post('/create', boxController.createBox);
router.get('/list', boxController.getAllBoxes);

module.exports = router;
