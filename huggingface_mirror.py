import os
import requests
import aiohttp
from urllib.parse import urlparse

# Set HuggingFace mirror environment variables
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
# os.environ['GIT_HUB_ENDPOINT'] = 'https://ghfast.top/https://github.com/'

# Use certifi to get the correct certificate path
import certifi
cert_path = certifi.where()
os.environ['SSL_CERT_FILE'] = cert_path

# Patch requests to redirect GitHub URLs
def patch_requests_for_github_mirror():
    original_request = requests.Session.request
    
    def patched_request(self, method, url, **kwargs):
        parsed = urlparse(url)
        # Add redirect for GitHub domains
        if parsed.netloc in ("github.com", "raw.githubusercontent.com"):
            url = url.replace("https://github.com", "https://ghfast.top/https://github.com")
            url = url.replace("https://raw.githubusercontent.com", "https://ghfast.top/https://raw.githubusercontent.com")
        # Ensure SSL cert is used
        if 'verify' not in kwargs:
            kwargs['verify'] = cert_path
        return original_request(self, method, url, **kwargs)
    
    requests.Session.request = patched_request

# Patch aiohttp to redirect GitHub URLs and use proper SSL cert
def patch_aiohttp_for_github_mirror():
    import ssl
    
    # Create SSL context directly with certifi certificates
    ssl_context = ssl.create_default_context(cafile=cert_path)
    
    # Store original session request method
    original_session_request = aiohttp.ClientSession._request
    
    async def patched_session_request(self, method, url, **kwargs):
        parsed = urlparse(url)
        # Add redirect for GitHub domains
        if parsed.netloc in ("github.com", "raw.githubusercontent.com"):
            url = url.replace("https://github.com", "https://ghfast.top/https://github.com")
            url = url.replace("https://raw.githubusercontent.com", "https://ghfast.top/https://raw.githubusercontent.com")
        # Ensure SSL context is used
        if 'ssl' not in kwargs:
            kwargs['ssl'] = ssl_context
        return await original_session_request(self, method, url, **kwargs)
    
    # Apply patch to ClientSession request method
    aiohttp.ClientSession._request = patched_session_request
    
    # Patch TCPConnector to use the SSL context by default
    original_connector_init = aiohttp.TCPConnector.__init__
    
    def patched_connector_init(self, **kwargs):
        if 'ssl' not in kwargs:
            kwargs['ssl'] = ssl_context
        original_connector_init(self, **kwargs)
    
    aiohttp.TCPConnector.__init__ = patched_connector_init

# Apply patches when this module is imported
patch_requests_for_github_mirror()
patch_aiohttp_for_github_mirror()