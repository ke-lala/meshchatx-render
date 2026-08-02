# ---------------------------------------------------
# 阶段 1: 编译前端 (若项目包含 Node前端项目，如 web/client 目录)
# ---------------------------------------------------
FROM node:20-alpine AS frontend-builder
WORKDIR /app/web

# 复制前端依赖项并安装
COPY web/package*.json ./
RUN npm ci

# 复制前端源码并构建打包
COPY web/ ./
RUN npm run build

# ---------------------------------------------------
# 阶段 2: 编译 Go 后端
# ---------------------------------------------------
FROM golang:1.22-alpine AS backend-builder
WORKDIR /app

# 安装必要的系统构建工具
RUN apk add --no-cache git gcc musl-dev

# 复制 Go 依赖定义文件
COPY go.mod go.sum ./
RUN go mod download

# 复制源码
COPY . .

# 将阶段 1 编译好的前端静态文件复制到 Go 后端可以读取或嵌入的目录
# (假设 Go 使用 Go 1.16+ 的 //go:embed 指令嵌入 web/dist)
COPY --from=frontend-builder /app/web/dist ./web/dist

# 编译生成可执行文件 (关闭 CGO 提升移植性)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o meshchatx .

# ---------------------------------------------------
# 阶段 3: 最终运行环境 (轻量 Alpine)
# ---------------------------------------------------
FROM alpine:latest

# 安装基础证书和时区数据
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# 从编译阶段复制二进制文件
COPY --from=backend-builder /app/meshchatx .

# 如果没有使用 embed 嵌入前端，需要单独把前端产物拷过来：
# COPY --from=frontend-builder /app/web/dist ./web/dist

# Render 会通过 PORT 环境变量动态注入端口，默认暴露 8080
EXPOSE 8080

# 启动应用
CMD ["./meshchatx"]
