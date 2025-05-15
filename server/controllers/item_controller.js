// controllers/item_controller.js
const Item = require('../models/item');

const itemController = {
  // 创建物品
  createItem: async (req, res) => {
    try {
      const { boxId, name, note, imagePath, expiryDate } = req.body;
      const item = new Item({
        boxId,
        name,
        note,
        imagePath,
        expiryDate,
        posX: 50,
        posY: 100,
        scale: 1.0
      });
      await item.save();
      res.json(item);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 获取盒子内的所有物品
  getItemsByBoxId: async (req, res) => {
    try {
      const items = await Item.find({ boxId: req.params.boxId });
      res.json(items);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新物品
  updateItem: async (req, res) => {
    try {
      const item = await Item.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
      );
      res.json(item);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 删除物品
  deleteItem: async (req, res) => {
    try {
      await Item.findByIdAndDelete(req.params.id);
      res.json({ message: '物品已删除' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 搜索物品
  searchItems: async (req, res) => {
    try {
      const { query, boxId } = req.query;
      const items = await Item.find({
        boxId,
        $or: [
          { name: { $regex: query, $options: 'i' } },
          { note: { $regex: query, $options: 'i' } }
        ]
      });
      res.json(items);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 获取过期物品
  getExpiredItems: async (req, res) => {
    try {
      const { boxId } = req.query;
      const now = new Date();
      const items = await Item.find({
        boxId,
        expiryDate: { $lt: now }
      });
      res.json(items);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新物品位置
  updateItemPosition: async (req, res) => {
    try {
      const { posX, posY } = req.body;
      const item = await Item.findByIdAndUpdate(
        req.params.id,
        { posX, posY },
        { new: true }
      );
      res.json(item);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新物品缩放
  updateItemScale: async (req, res) => {
    try {
      const { scale } = req.body;
      const item = await Item.findByIdAndUpdate(
        req.params.id,
        { scale },
        { new: true }
      );
      res.json(item);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = itemController;
