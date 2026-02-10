# HuggingFace 镜像外部注入方案

本文档介绍了如何在不修改 `main.py` 的情况下，为 ComfyUI 注入 HuggingFace 镜像配置。

## 方法一：使用自定义启动脚本

1. **创建外部配置文件**
   - 创建 `huggingface_mirror.py` 文件，包含所有 HuggingFace 镜像和 GitHub 重定向代码
   - 创建 `start_with_hf_mirror.py` 自定义启动脚本

2. **使用自定义脚本启动 ComfyUI**
   ```bash
   python start_with_hf_mirror.py
   ```

## 方法二：使用环境变量和 Python -c 参数

如果不想创建额外的脚本文件，可以直接使用以下命令启动：

```bash
python -c "
import os
import sys
import requests
from urllib.parse import urlparse

# 设置环境变量
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
os.environ['SSL_CERT_FILE'] = '/home/ck/myProjects/ComfyUI/my_env/lib/python3.12/site-packages/certifi/cacert.pem'

# 修补 requests
original_request = requests.Session.request
def patched_request(self, method, url, **kwargs):
    parsed = urlparse(url)
    if parsed.netloc in ['github.com', 'raw.githubusercontent.com']:
        url = url.replace('https://github.com', 'https://ghfast.top/https://github.com')
        url = url.replace('https://raw.githubusercontent.com', 'https://ghfast.top/https://raw.githubusercontent.com')
    return original_request(self, method, url, **kwargs)
requests.Session.request = patched_request

# 导入并运行 main
import main
"
```

## 方法三：使用 Python 路径注入

1. **只创建配置文件**
   - 仅创建 `huggingface_mirror.py` 文件

2. **通过环境变量注入**
   ```bash
   PYTHONPATH=. python -c "import huggingface_mirror; import main"
   ```

## 管理本地配置文件

为了避免将本地配置文件提交到版本控制系统，建议将这些文件添加到 `.gitignore`：

```bash
echo "huggingface_mirror.py" >> .gitignore
echo "start_with_hf_mirror.py" >> .gitignore
echo "README_HF_MIRROR.md" >> .gitignore
```

## 注意事项

1. 确保 `huggingface_mirror.py` 文件中的路径配置正确，特别是 `SSL_CERT_FILE` 路径
2. 如果使用自定义启动脚本，请确保脚本具有执行权限：
   ```bash
   chmod +x start_with_hf_mirror.py
   ```
3. 这些方法都会在程序启动时应用配置，与直接修改 `main.py` 具有相同的效果
