// controllers/box_controller.js
const Box = require('../models/box');
const Item = require('../models/item');

const boxController = {
  // 创建盒子
  createBox: async (req, res) => {
    try {
      const { name, description, type, isPublic, themeColor } = req.body;
      const box = new Box({
        name,
        description,
        type,
        isPublic,
        themeColor,
        itemCount: 0,
        hasExpiredItems: false
      });
      await box.save();
      res.json(box);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 获取所有盒子
  getAllBoxes: async (req, res) => {
    try {
      const boxes = await Box.find();
      res.json(boxes);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新盒子
  updateBox: async (req, res) => {
    try {
      const box = await Box.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
      );
      res.json(box);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 删除盒子
  deleteBox: async (req, res) => {
    try {
      await Box.findByIdAndDelete(req.params.id);
      // 同时删除盒子内的所有物品
      await Item.deleteMany({ boxId: req.params.id });
      res.json({ message: '盒子已删除' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 检查过期物品
  checkExpiredItems: async (req, res) => {
    try {
      const now = new Date();
      const expiredItems = await Item.find({
        boxId: req.params.id,
        expiryDate: { $lt: now }
      });
      
      const hasExpired = expiredItems.length > 0;
      await Box.findByIdAndUpdate(
        req.params.id,
        { hasExpiredItems: hasExpired }
      );
      
      res.json({ hasExpired, count: expiredItems.length });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新盒子主题
  updateBoxTheme: async (req, res) => {
    try {
      const { themeColor } = req.body;
      const box = await Box.findByIdAndUpdate(
        req.params.id,
        { themeColor },
        { new: true }
      );
      res.json(box);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新盒子封面
  updateBoxCover: async (req, res) => {
    try {
      const { coverImage } = req.body;
      const box = await Box.findByIdAndUpdate(
        req.params.id,
        { coverImage },
        { new: true }
      );
      res.json(box);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = boxController;
