// server.js
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const authRoutes = require('./routes/auth_routes');
const boxRoutes = require('./routes/box_routes');
const itemRoutes = require('./routes/item_routes');

const app = express();
app.use(cors());
app.use(express.json());

// 静态访问uploads目录
app.use('/uploads', express.static('uploads'));

// 文件上传配置
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage: storage });

app.post('/upload', upload.single('file'), (req, res) => {
  res.send(`uploads/${req.file.filename}`);
});

// 路由
app.use('/auth', authRoutes);
app.use('/box', boxRoutes);
app.use('/item', itemRoutes);

// 启动服务器
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
