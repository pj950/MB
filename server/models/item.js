const mongoose = require('mongoose');

const itemSchema = new mongoose.Schema({
  boxId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Box',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  note: {
    type: String,
    default: ''
  },
  imagePath: {
    type: String,
    required: true
  },
  expiryDate: {
    type: Date,
    default: null
  },
  posX: {
    type: Number,
    default: 50
  },
  posY: {
    type: Number,
    default: 100
  },
  scale: {
    type: Number,
    default: 1.0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// 更新时自动更新updatedAt字段
itemSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Item', itemSchema); 