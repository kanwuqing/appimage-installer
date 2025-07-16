> 中文版本(The English version comes after the Chinese version)

# AppImage 安装工具

在Linux系统上轻松安装和管理AppImage应用程序，提供系统级和用户级安装选项。

## 功能特点

- 自动提取AppImage元数据
- 用户级安装（无需root权限）
- 系统级安装（整个系统可用）
- 自动创建：
  - 桌面启动器 (.desktop文件)
  - 应用程序图标
  - 终端命令
- 冲突检测

## 安装方法

```bash
git clone https://github.com/kanwuqing/appimage-installer.git
cd appimage-installer
chmod +x install_appimage.sh uninstall_appimage.sh
```

## 使用示例

**用户级安装（推荐）**
```bash
./install_appimage.sh ~/Downloads/MyApp.AppImage
```

**系统级安装（需要sudo）**
```bash
sudo ./install_appimage.sh ~/Downloads/MyApp.AppImage --system
```

**卸载应用程序(系统级卸载同样需要sudo)**
```bash
./uninstall_appimage.sh MyApp
```

## 工作原理

1. 提取AppImage中的元数据（.desktop文件和图标）
2. 将文件部署到标准位置：
   - 应用程序：`~/.local/apps/` 或 `/opt/`
   - 桌面启动器：`~/.local/share/applications/` 或 `/usr/share/applications/`
   - 图标：`~/.local/share/icons/` 或 `/usr/share/icons/`
   - 终端命令：`~/.local/bin/` 或 `/usr/local/bin/`

3. 更新桌面数据库

## 常见问题

**Q：为什么需要用户级安装？**  
A：避免污染系统目录，不需要sudo权限，更适合多用户系统

## 贡献指南
欢迎提交PR！请确保：
1. 通过ShellCheck验证脚本
2. 保持兼容POSIX的Bash语法
3. 添加新功能的测试用例

## 许可证
GP - 自由使用和修改
### 技术说明

1. **安全特性**：
   - 安装前用户确认冲突覆盖
   - 严格的输入验证
   - 使用临时目录进行安全提取

2. **路径处理**：
   - 用户级路径遵循XDG规范
   - 系统级路径使用标准FHS
   - 自动图标类型检测（PNG/SVG）

3. **兼容性**：
   - 支持所有基于glibc的Linux发行版
   - 兼容多数AppImage生成工具
   - 处理带空格的文件名

4. **错误处理**：
   - 关键操作前验证存在性
   - 提供明确错误信息
   - 避免部分安装状态



> English Edition
# AppImage Installation Tool

Easily install and manage AppImage applications on Linux systems, offering both system-level and user-level installation options.

## Functional Features

Automatically extract AppImage metadata
- User-level installation (no root privileges required)
System-level installation (available for the entire system)
- Automatically created:
- Desktop Launcher (.desktop file)
- Application icon
Terminal Command
Conflict detection

## Installation Method

```bash
git clone https://github.com/kanwuqing/appimage-installer.git
cd appimage-installer
chmod +x install_appimage.sh uninstall_appimage.sh
```

## Usage Example

"User-level installation (Recommended).
```bash
./install_appimage.sh ~/Downloads/MyApp.AppImage
```

System-level installation (sudo is required)
```bash
sudo ./install_appimage.sh ~/Downloads/MyApp.AppImage --system
```

Uninstall the application (system-level uninstallation also requires sudo)
```bash
./uninstall_appimage.sh MyApp
```

Working principle

1. Extract metadata from the AppImage (.desktop files and ICONS)
2. Deploy the file to the standard location
- Application: '~/.local/apps/' or '/opt/'
- desktop launcher: ` ~ /. Local/share/applications / ` or ` / usr/share/applications / `
- icon: ` ~ / local/share/ICONS / ` or ` / usr/share/ICONS / `
- Terminal commands: '~/.local/bin/' or '/usr/local/bin/'

3. Update the desktop database

Frequently Asked Questions

Q: Why is user-level installation necessary? **
A: It avoids contaminating the system directory, does not require sudo permissions, and is more suitable for multi-user systems

"Contribution Guide.
Welcome to submit your PR! Please ensure:
1. Verify the script through ShellCheck
2. Maintain POSIX-compatible Bash syntax
3. Add test cases for new functions

"License"
GP - Free use and modification
Technical Description

1. ** Safety Features ** :
Before installation, the user confirms conflict coverage
- Strict input validation
- Use a temporary directory for secure extraction

2. "Path Processing" :
The user-level path follows the XDG specification
The system-level path uses the standard FHS
- Automatic Icon type detection (PNG/SVG)

3. "Compatibility"
- Supports all Linux distributions based on glibc
- Compatible with most AppImage generation tools
- Handle file names with Spaces

4. "Error Handling" :
Verify the existence before critical operations
- Provide clear error information
- Avoid partial installation status