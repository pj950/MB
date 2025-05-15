// routes/item_routes.js
const express = require('express');
const router = express.Router();
const itemController = require('../controllers/item_controller');

// 基础CRUD操作
router.post('/create', itemController.createItem);
router.get('/list/:boxId', itemController.getItemsByBoxId);
router.put('/update/:id', itemController.updateItem);
router.delete('/delete/:id', itemController.deleteItem);

// 搜索和过滤
router.get('/search', itemController.searchItems);
router.get('/expired', itemController.getExpiredItems);

// 位置和缩放更新
router.put('/position/:id', itemController.updateItemPosition);
router.put('/scale/:id', itemController.updateItemScale);

module.exports = router;
