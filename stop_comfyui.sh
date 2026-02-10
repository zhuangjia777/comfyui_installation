#!/bin/bash

# ComfyUI停止脚本
# 此脚本将停止ComfyUI进程并清理相关文件

echo "正在停止ComfyUI服务..."

# 检查PID文件是否存在
if [ -f "/home/ck/myProjects/ComfyUI/comfyui.pid" ]; then
    # 读取PID
    PID=$(cat /home/ck/myProjects/ComfyUI/comfyui.pid)
    echo "找到ComfyUI PID: $PID"
    
    # 检查进程是否仍在运行
    if ps -p $PID > /dev/null; then
        # 停止进程
        kill $PID
        echo "已发送停止信号给进程 $PID"
        
        # 等待进程停止
        sleep 2
        
        # 检查进程是否已停止
        if ps -p $PID > /dev/null; then
            echo "进程未正常停止，尝试强制终止..."
            kill -9 $PID
            echo "已强制终止进程 $PID"
        else
            echo "ComfyUI进程已成功停止"
        fi
    else
        echo "ComfyUI进程 (PID: $PID) 未在运行"
    fi
    
    # 删除PID文件
    rm -f /home/ck/myProjects/ComfyUI/comfyui.pid
    echo "已删除PID文件"
else
    echo "未找到ComfyUI PID文件"
fi

# 查找并停止所有可能的ComfyUI进程
echo "查找其他可能的ComfyUI进程..."
PIDS=$(pgrep -f "python.*main.py")
if [ -n "$PIDS" ]; then
    echo "找到以下ComfyUI相关进程: $PIDS"
    for PID in $PIDS; do
        echo "停止进程 $PID"
        kill $PID
    done
    sleep 2
    
    # 检查是否还有进程未停止
    REMAINING=$(pgrep -f "python.*main.py")
    if [ -n "$REMAINING" ]; then
        echo "以下进程未正常停止，尝试强制终止: $REMAINING"
        for PID in $REMAINING; do
            kill -9 $PID
        done
    fi
else
    echo "未找到其他运行的ComfyUI进程"
fi

# 检查端口8188是否仍被占用
echo "检查端口8188..."
if netstat -tlnp 2>/dev/null | grep -q ":8188 "; then
    echo "端口8188仍被占用，尝试查找并停止相关进程..."
    PORT_PID=$(netstat -tlnp 2>/dev/null | grep ":8188 " | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$PORT_PID" ]; then
        echo "停止占用端口8188的进程: $PORT_PID"
        kill $PORT_PID
        sleep 2
        if ps -p $PORT_PID > /dev/null; then
            kill -9 $PORT_PID
        fi
    fi
else
    echo "端口8188未被占用"
fi

echo "ComfyUI停止操作完成"
