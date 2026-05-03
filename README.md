# rclone-over-autossh

基于 systemd 管理的 autossh 持久化 SSH 隧道 + rclone SFTP 服务方案。

## 使用方法

```sh
git clone https://git.7-0.cc/zero/rclone-over-autossh.git
cd rclone-over-autossh
sudo make install
```

看到如下输出表示成功:

```sh
[SUCCESS] Installation completed!

Next steps:
1. View and edit /etc/rclone-over-autossh/service.conf to set your remote host and credentials.
   nano /etc/rclone-over-autossh/service.conf

2. View the public key (add to remote server authorized_keys):
   cat /etc/rclone-over-autossh/ssh_key.pub

3. Enable and start the service:
   make enable

4. Check service status:
   make status

5. View logs:
   make logs
```

按照步骤:

1. 修改配置文件
2. 添加公钥到远程服务器
3. 重启并测试

```sh
rclone ls :sftp,host=127.0.0.1,port=2026,user=shared,pass=$(rclone obscure <password>):/
```
