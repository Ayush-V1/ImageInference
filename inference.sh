#!/bin/bash

# Check if the current directory is ImageInference. If not, change to it.
if [[ $(basename "$PWD") != "ImageInference" ]]; then
    if [ -d "ImageInference" ]; then
        cd ImageInference
    else
        echo "Error: ImageInference directory not found!"
        exit 1
    fi
fi

# Install necessary packages
pip install --upgrade pip
pip install torch
pip install -e .

# Start the first server and wait for it to complete
python3 -m llava.serve.controller --host 0.0.0.0 --port 10000 > log.txt 2>&1

# Start the second server and wait for it to complete
python -m llava.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path liuhaotian/llava-v1.5-7b > log2.txt 2>&1

# Set the environment variables
export GRADIO_SERVER_NAME='0.0.0.0'
export GRADIO_SERVER_PORT='3000'

# Start the final server in the background with nohup
nohup python3 -m llava.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload > log3.txt 2>&1 &