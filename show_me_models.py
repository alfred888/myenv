#!/usr/bin/env python3
import os
import json
from pathlib import Path
from typing import Dict, List, Optional

# 常见的大模型存储路径
COMMON_MODEL_PATHS = [
    # Hugging Face 默认路径
    os.path.expanduser("~/.cache/huggingface/hub"),
    # Transformers 默认路径
    os.path.expanduser("~/.cache/torch/transformers"),
    # PyTorch 默认路径
    os.path.expanduser("~/.cache/torch/hub"),
    # 自定义路径
    os.path.expanduser("~/models"),
    os.path.expanduser("~/Downloads/models"),
]

def get_model_info(model_path: Path) -> Dict:
    """获取模型信息"""
    info = {
        "name": model_path.name,
        "path": str(model_path),
        "size": get_folder_size(model_path),
        "type": "unknown"
    }
    
    # 尝试确定模型类型
    if "huggingface" in str(model_path):
        info["type"] = "Hugging Face"
    elif "transformers" in str(model_path):
        info["type"] = "Transformers"
    elif "torch" in str(model_path):
        info["type"] = "PyTorch"
    
    return info

def get_folder_size(path: Path) -> str:
    """计算文件夹大小并返回人类可读的格式"""
    total_size = 0
    for dirpath, _, filenames in os.walk(path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if not os.path.islink(fp):
                total_size += os.path.getsize(fp)
    
    # 转换为人类可读的格式
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if total_size < 1024.0:
            return f"{total_size:.2f} {unit}"
        total_size /= 1024.0
    return f"{total_size:.2f} PB"

def find_model_files() -> List[Dict]:
    """查找所有模型文件"""
    found_models = []
    
    for base_path in COMMON_MODEL_PATHS:
        if not os.path.exists(base_path):
            continue
            
        for root, dirs, files in os.walk(base_path):
            # 检查是否包含模型文件
            if any(f.endswith(('.bin', '.pt', '.pth', '.safetensors', '.gguf')) for f in files):
                model_path = Path(root)
                model_info = get_model_info(model_path)
                found_models.append(model_info)
    
    return found_models

def main():
    print("正在扫描模型文件...")
    models = find_model_files()
    
    if not models:
        print("未找到任何模型文件。")
        return
    
    print("\n找到以下模型文件：")
    print("-" * 80)
    for model in models:
        print(f"模型名称: {model['name']}")
        print(f"存储路径: {model['path']}")
        print(f"模型类型: {model['type']}")
        print(f"文件大小: {model['size']}")
        print("-" * 80)

if __name__ == "__main__":
    main() 