#!/usr/bin/env bash

# Change to the script directory
cd "$(dirname "$0")"
pip install -r requirements.txt -t python/
zip -r layer.zip python/