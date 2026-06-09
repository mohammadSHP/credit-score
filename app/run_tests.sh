#!/bin/bash
set -e
pip install -r /app/requirements.txt -q
pytest /app/tests/ -v --tb=short
