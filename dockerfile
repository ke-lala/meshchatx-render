FROM ghcr.io/quad4-software/meshchatx:latest

# 确保环境变量绑定到所有接口，端口设为 Render 要求的 PORT 或默认 8000
ENV HOST=0.0.0.0
ENV PORT=8000

# 暴露端口
EXPOSE 8000

# 启动命令（根据官方镜像实际入口调整，通常支持 --host 和 --port 参数，或通过环境变量控制）
CMD ["meshchat", "--headless", "--host", "0.0.0.0", "--port", "8000"]
