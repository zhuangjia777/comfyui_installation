#!/bin/bash

# ComfyUI服务卸载脚本
# 此脚本将移除ComfyUI的systemd服务

echo "正在移除ComfyUI开机自启动..."

# 停止ComfyUI服务
sudo systemctl stop comfyui.service

# 禁用ComfyUI服务
sudo systemctl disable comfyui.service

# 删除服务文件
sudo rm /etc/systemd/system/comfyui.service

# 重新加载systemd配置
sudo systemctl daemon-reload

echo "ComfyUI服务已卸载！"
