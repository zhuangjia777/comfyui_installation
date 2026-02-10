#!/bin/bash

# ComfyUI服务安装脚本
# 此脚本将安装systemd服务以实现ComfyUI开机自启动

echo "正在设置ComfyUI开机自启动..."

# 确保启动脚本有执行权限
chmod +x /home/ck/myProjects/ComfyUI/start_comfyui.sh

# 复制服务文件到systemd目录
sudo cp /home/ck/myProjects/ComfyUI/comfyui.service /etc/systemd/system/

# 重新加载systemd配置
sudo systemctl daemon-reload

# 启用ComfyUI服务
sudo systemctl enable comfyui.service

# 启动ComfyUI服务
sudo systemctl start comfyui.service

echo "ComfyUI服务已安装并启动！"
echo "您可以使用以下命令管理服务："
echo "  启动服务: sudo systemctl start comfyui"
echo "  停止服务: sudo systemctl stop comfyui"
echo "  重启服务: sudo systemctl restart comfyui"
echo "  查看状态: sudo systemctl status comfyui"
echo "  查看日志: sudo journalctl -u comfyui -f"
