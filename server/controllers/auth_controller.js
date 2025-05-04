// controllers/auth_controller.js
exports.login = (req, res) => {
    const { method, account, code } = req.body;
    if (
      (method === 'phone' && account === '18812345678' && code === '1234') ||
      (method === 'email' && account === 'testuser@example.com' && code === '1234')
    ) {
      res.json({ success: true });
    } else {
      res.status(401).json({ success: false, message: '登录失败' });
    }
  };
  