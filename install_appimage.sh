#!/bin/bash

# 检查参数
if [ $# -eq 0 ]; then
    echo "Usage: $0 <AppImage文件> [--system]"
    exit 1
fi

APPIMAGE_PATH=$1
APPIMAGE_FILE=$(basename -- "$APPIMAGE_PATH")
APP_NAME="${APPIMAGE_FILE%.*}"  # 去除扩展名

INSTALL_MODE="user"
if [ "$2" == "--system" ]; then
    INSTALL_MODE="system"
fi

# 验证文件
if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "错误: 文件 $APPIMAGE_PATH 不存在"
    exit 1
fi

if ! [[ $APPIMAGE_PATH =~ \.AppImage$ ]]; then
    echo "错误: 文件必须是AppImage格式"
    exit 1
fi

# 设置安装路径
if [ "$INSTALL_MODE" == "system" ]; then
    APP_DIR="/opt/$APP_NAME"
    BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
    ICON_DIR="/usr/share/icons/hicolor"
    MIME_DIR="/usr/share/mime"
else
    HOME_DIR=~
    APP_DIR="$HOME_DIR/.local/apps/$APP_NAME"
    BIN_DIR="$HOME_DIR/.local/bin"
    DESKTOP_DIR="$HOME_DIR/.local/share/applications"
    ICON_DIR="$HOME_DIR/.local/share/icons"
    mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"
fi

# 赋予执行权限
chmod +x "$APPIMAGE_PATH"

# 提取AppImage内容
echo "正在提取AppImage内容..."
TEMP_DIR=$(mktemp -d)
echo "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
"$APPIMAGE_PATH" --appimage-extract >/dev/null 2>&1 || { echo "解压失败！"; rm -rf "$TMP_DIR"; exit 1; }
cd - >/dev/null || exit 1

# 查找关键文件
DESKTOP_FILE=$(find "$TEMP_DIR/squashfs-root" -name "*.desktop" | head -n 1)
ICON_FILE=$(find "$TEMP_DIR/squashfs-root" -name "*.png" -o -name "*.svg" | head -n 1)
APP_DISPLAY_NAME=$(grep -oP 'Name=\K.*' "$DESKTOP_FILE" | head -n 1)
DESKTOP_FILE_NAME=$(basename -- "$DESKTOP_FILE")

# 检查冲突
if [ -f "$BIN_DIR/$APP_NAME" ]; then
    read -p "发现已存在的命令 $APP_NAME，是否覆盖？ [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# 复制文件
echo "正在安装 $APP_DISPLAY_NAME..."
mkdir -p "$APP_DIR"
cp "$APPIMAGE_PATH" "$APP_DIR/$APPIMAGE_FILE"

# 复制并重命名图标
if [ -n "$ICON_FILE" ]; then
    ICON_EXT="${ICON_FILE##*.}"
    ICON_TARGET="$ICON_DIR/$APP_NAME.$ICON_EXT"
    cp "$ICON_FILE" "$ICON_TARGET"
else
    ICON_TARGET=""
fi

# 处理桌面启动器文件
DESKTOP_TARGET="$DESKTOP_DIR/$APP_NAME.desktop"

# 创建新的启动器文件
{
    grep -v '^Exec=' "$DESKTOP_FILE" | grep -v '^Icon='
    echo "Exec=\"$APP_DIR/$APPIMAGE_FILE\" %U"
    if [ -n "$ICON_TARGET" ]; then
        echo "Icon=$ICON_TARGET"
    fi
} > "$DESKTOP_TARGET"

# 创建终端命令
ln -sf "$APP_DIR/$APPIMAGE_FILE" "$BIN_DIR/$APP_NAME"

# 更新数据库
if [ "$INSTALL_MODE" == "system" ]; then
    sudo update-desktop-database
    sudo update-mime-database "$MIME_DIR"
else
    update-desktop-database "$DESKTOP_DIR"
fi

# 清理临时文件
rm -rf "$TEMP_DIR"

echo "安装完成！"
echo "应用程序位置: $APP_DIR/$APPIMAGE_FILE"
echo "终端命令: $APP_NAME"
echo "桌面启动器: $DESKTOP_TARGET"