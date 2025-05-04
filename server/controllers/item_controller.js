// controllers/item_controller.js
let items = []; // 内存模拟物品数据

exports.createItem = (req, res) => {
  const item = req.body;
  item.id = Date.now();
  items.push(item);
  res.json(item);
};

exports.getItemsByBoxId = (req, res) => {
  const { boxId } = req.params;
  const boxItems = items.filter(item => item.boxId == boxId);
  res.json(boxItems);
};
