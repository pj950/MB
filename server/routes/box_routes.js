// routes/box_routes.js
const express = require('express');
const router = express.Router();
const boxController = require('../controllers/box_controller');

// 基础CRUD操作
router.post('/create', boxController.createBox);
router.get('/list', boxController.getAllBoxes);
router.put('/update/:id', boxController.updateBox);
router.delete('/delete/:id', boxController.deleteBox);

// 特殊功能
router.get('/expired-items/:id', boxController.checkExpiredItems);
router.put('/theme/:id', boxController.updateBoxTheme);
router.put('/cover/:id', boxController.updateBoxCover);

module.exports = router;
