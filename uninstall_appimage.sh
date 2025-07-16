#!/bin/bash

# 检查参数
if [ $# -eq 0 ]; then
    echo "Usage: $0 <应用名称> [--system]"
    echo "示例:"
    echo "  $0 myapp          # 卸载用户级安装"
    echo "  $0 myapp --system # 卸载系统级安装"
    exit 1
fi

APP_NAME=$1
INSTALL_MODE="user"
if [ "$2" == "--system" ]; then
    INSTALL_MODE="system"
fi

# 设置路径
if [ "$INSTALL_MODE" == "system" ]; then
    APP_DIR="/opt/$APP_NAME"
    BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
    ICON_DIR="/usr/share/icons/hicolor"
    MIME_DIR="/usr/share/mime"
    USE_SUDO="sudo"
else
    HOME_DIR=~
    APP_DIR="$HOME_DIR/.local/apps/$APP_NAME"
    BIN_DIR="$HOME_DIR/.local/bin"
    DESKTOP_DIR="$HOME_DIR/.local/share/applications"
    ICON_DIR="$HOME_DIR/.local/share/icons"
    USE_SUDO=""
fi

# 检查是否已安装
if [ ! -d "$APP_DIR" ]; then
    echo "错误: 未找到 $APP_NAME 的安装目录"
    exit 1
fi

# 获取桌面文件名
DESKTOP_FILE="$DESKTOP_DIR/$APP_NAME.desktop"

# 确认卸载
read -p "确定要卸载 $APP_NAME? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "卸载已取消"
    exit 0
fi

# 删除文件
echo "正在卸载 $APP_NAME..."

# 删除主程序目录
$USE_SUDO rm -rf "$APP_DIR"

# 删除桌面启动器
if [ -f "$DESKTOP_FILE" ]; then
    $USE_SUDO rm -f "$DESKTOP_FILE"
fi

# 删除终端命令
if [ -L "$BIN_DIR/$APP_NAME" ] || [ -f "$BIN_DIR/$APP_NAME" ]; then
    $USE_SUDO rm -f "$BIN_DIR/$APP_NAME"
fi

# 删除图标文件
ICON_FILES=(
    "$ICON_DIR/16x16/apps/$APP_NAME.png"
    "$ICON_DIR/32x32/apps/$APP_NAME.png"
    "$ICON_DIR/48x48/apps/$APP_NAME.png"
    "$ICON_DIR/64x64/apps/$APP_NAME.png"
    "$ICON_DIR/128x128/apps/$APP_NAME.png"
    "$ICON_DIR/256x256/apps/$APP_NAME.png"
    "$ICON_DIR/512x512/apps/$APP_NAME.png"
    "$ICON_DIR/scalable/apps/$APP_NAME.svg"
    "$ICON_DIR/$APP_NAME.png"
    "$ICON_DIR/$APP_NAME.svg"
)

for icon in "${ICON_FILES[@]}"; do
    if [ -f "$icon" ]; then
        $USE_SUDO rm -f "$icon"
    fi
done

# 更新数据库
if [ "$INSTALL_MODE" == "system" ]; then
    $USE_SUDO update-desktop-database
    $USE_SUDO update-mime-database "$MIME_DIR"
else
    update-desktop-database "$DESKTOP_DIR"
fi

echo "卸载完成！"
echo "已移除:"
echo "  - 应用程序目录: $APP_DIR"
echo "  - 桌面启动器: $DESKTOP_DIR/$APP_NAME.desktop"
echo "  - 终端命令: $BIN_DIR/$APP_NAME"