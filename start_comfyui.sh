#!/bin/bash

# ComfyUI启动脚本
# 此脚本将激活conda环境并启动ComfyUI，然后重启FRP服务

# 设置工作目录
cd /home/ck/myProjects/ComfyUI/

# 激活conda环境
source /home/ck/miniconda3/etc/profile.d/conda.sh
conda activate /home/ck/myProjects/ComfyUI/my_env

# 创建日志目录
mkdir -p /home/ck/myProjects/ComfyUI/logs

# 在后台启动ComfyUI，并将输出重定向到日志文件
nohup python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header --output-directory /mnt/SD01/projects/ComfyUI_base/output --input-directory /mnt/SD01/projects/ComfyUI_base/input --user-directory /mnt/SD01/projects/ComfyUI_base/user  > /home/ck/myProjects/ComfyUI/logs/comfyui.log 2>&1 &
COMFYUI_PID=$!

# 等待ComfyUI启动完成
echo "等待ComfyUI启动..."
sleep 12

# 检查ComfyUI是否成功启动
if ps -p $COMFYUI_PID > /dev/null; then
    echo "ComfyUI已成功启动，PID: $COMFYUI_PID"
    echo "ComfyUI日志文件: /home/ck/myProjects/ComfyUI/logs/comfyui.log"

    # 重启FRP服务
    echo "正在重启FRP服务..."
    
    # 直接停止FRP进程
    sudo pkill frpc
    echo "已停止FRP服务"
    
    # 启动FRP服务
    /home/ck/myProjects/frp_0.65.0_linux_amd64/frpc -c /home/ck/myProjects/frp_0.65.0_linux_amd64/frpc.toml
    echo "FRP服务已成功启动"
    
    # 检查FRP服务状态
    sleep 2
    if pgrep -f "frp" > /dev/null; then
        echo "FRP服务已成功重启"
    else
        echo "FRP服务重启失败，请手动检查"
    fi
else
    echo "ComfyUI启动失败，请检查日志文件: /home/ck/myProjects/ComfyUI/logs/comfyui.log"
    exit 1
fi

# 保存ComfyUI PID到文件，方便后续管理
echo $COMFYUI_PID > /home/ck/myProjects/ComfyUI/comfyui.pid

echo "启动脚本执行完成"
echo "ComfyUI PID: $COMFYUI_PID"
echo "您可以使用以下命令管理ComfyUI:"
echo "  查看状态: ps -p $COMFYUI_PID"
echo "  停止服务: kill $COMFYUI_PID"
echo "  查看日志: tail -f /home/ck/myProjects/ComfyUI/logs/comfyui.log"