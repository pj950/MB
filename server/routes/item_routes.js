// routes/item_routes.js
const express = require('express');
const router = express.Router();
const itemController = require('../controllers/item_controller');

router.post('/create', itemController.createItem);
router.get('/list/:boxId', itemController.getItemsByBoxId);

module.exports = router;
