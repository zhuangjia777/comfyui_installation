import os
import requests
from urllib.parse import urlparse

# Set HuggingFace mirror environment variables
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
# os.environ['GIT_HUB_ENDPOINT'] = 'https://ghfast.top/https://github.com/'
os.environ['SSL_CERT_FILE'] = '/home/ck/myProjects/ComfyUI/my_env/lib/python3.12/site-packages/certifi/cacert.pem'

# Patch requests to redirect GitHub URLs
def patch_requests_for_github_mirror():
    original_request = requests.Session.request
    
    def patched_request(self, method, url, **kwargs):
        parsed = urlparse(url)
        # Add redirect for raw.githubusercontent.com
        if parsed.netloc == "github.com" or parsed.netloc == "raw.githubusercontent.com":
            url = url.replace("https://github.com", "https://ghfast.top/https://github.com")
            url = url.replace("https://raw.githubusercontent.com", "https://ghfast.top/https://raw.githubusercontent.com")
        return original_request(self, method, url, **kwargs)
    
    requests.Session.request = patched_request

# Apply the patch when this module is imported
patch_requests_for_github_mirror()
