FROM python:3.11-slim

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 如果仓库中有 requirements.txt 则安装 Python 依赖
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# 复制项目所有文件
COPY . .

# 如果仓库中自带 setup.py 或 pyproject.toml，进行本地安装
RUN if [ -f setup.py ] || [ -f pyproject.toml ]; then pip install --no-cache-dir .; fi

# Render 会通过 PORT 环境变量注入端口，默认暴露 8080
ENV PORT=8080
EXPOSE 8080

# 启动命令：自动寻找可执行入口，如果找不到则尝试通过 python3 运行 main.py/app.py
CMD ["sh", "-c", "exec meshchatx || exec python3 main.py || exec python3 app.py"]
