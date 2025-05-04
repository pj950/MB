// controllers/box_controller.js
let boxes = []; // 内存模拟盒子数据

exports.createBox = (req, res) => {
  const box = req.body;
  box.id = Date.now();
  boxes.push(box);
  res.json(box);
};

exports.getAllBoxes = (req, res) => {
  res.json(boxes);
};
