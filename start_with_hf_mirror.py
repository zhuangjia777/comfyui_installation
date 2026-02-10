#!/usr/bin/env python3
"""
Custom startup script for ComfyUI with HuggingFace mirror injection.
This script loads the HuggingFace mirror configuration before running main.py.
"""

import sys
import os

# Add the current directory to Python path to ensure all modules are importable
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import the HuggingFace mirror configuration (this applies all patches)
import huggingface_mirror

# Now import and run main.py
import main
