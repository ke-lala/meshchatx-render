# ---------------------------------------------------
# 阶段 1: 编译 Go 后端
# ---------------------------------------------------
FROM golang:1.22-alpine AS builder

# 安装编译所需的依赖工具
RUN apk add --no-cache git gcc musl-dev

WORKDIR /app

# 复制 Go 依赖定义文件（这里改用 go.mod* 匹配，即使没有 go.sum 也不会报错）
COPY go.mod go.sum* ./

# 如果有依赖库则下载
RUN go mod download || true

# 复制整个项目源码
COPY . .

# 编译 MeshChatX 可执行文件
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o meshchatx .

# ---------------------------------------------------
# 阶段 2: 最终运行镜像
# ---------------------------------------------------
FROM alpine:latest

# 安装 SSL 证书和时区数据，确保网络通信与时区正常
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/meshchatx .

# 如果项目中有静态资源或配置文件目录，取消下面这行的注释（按需）：
# COPY --from=builder /app/static ./static

# Render 会动态传入 PORT 环境变量（默认 8080）
EXPOSE 8080

# 启动服务
CMD ["./meshchatx"]
