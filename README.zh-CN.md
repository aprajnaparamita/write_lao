# Write Lao（写老挝文）

通过逐笔画书写练习学习老挝文字母，并用智能闪卡系统积累词汇。

## 关于下载

应用的安装包（macOS、Windows、Linux、Android）发布在
[GitHub Releases](https://github.com/aprajnaparamita/write_lao/releases) 页面，
文件名带有平台和版本号。

注意：GitHub 在中国大陆访问不稳定，可能需要代理（VPN）才能打开下载页面。
如果无法下载，可以联系维护者直接索取安装包文件：微信联系方式见网站支持页
[writelao.xyz/support](https://writelao.xyz/support)。

安装提示：

| 平台 | 安装方法 |
|---|---|
| macOS | 打开 `.dmg`，把 Write Lao 拖进"应用程序"。首次启动：右键点击应用选"打开"（构建未签名，双击会被系统拦截）。 |
| Windows | 运行安装程序。若 SmartScreen 警告：选择"更多信息"→"仍要运行"（构建未签名）。 |
| Windows（便携版） | 解压 zip 到任意目录，运行 `write_lao.exe`，无需安装。 |
| Linux | `tar xzf write_lao-linux-<版本>.tar.gz`，然后运行 `./write_lao`。 |
| Android | 直接安装 APK，需允许浏览器或文件管理器"安装未知应用"；或用 adb：`adb install write_lao-android-<版本>.apk`。 |

这些是开源构建：完整 500 词词汇表已全部解锁，无需任何内购。应用完全离线运行，不联网也能使用。

## 从源码构建

### 网络适配（重要）

Flutter 官方的包仓库（pub.dev）和 SDK 下载服务器在中国大陆访问不稳定。构建前请设置
Flutter 中国社区镜像（[flutter-io.cn](https://flutter-io.cn)）：

```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

建议把这两行写进 `~/.bashrc` 或 `~/.zshrc`。

### 构建步骤

```bash
cd write_lao

# 安装依赖
flutter pub get

# 代码生成（Freezed 模型等）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行开源版本（完整词汇表已解锁）
flutter run --dart-define=APP_VARIANT=open
```

`APP_VARIANT` 是两个产品版本的唯一区别：`open` 解锁全部词汇，`store` 保留内购。
默认值为 `store`。

打包：

```bash
make apk        # Android 开源 APK -> outputs/write_lao-android-<版本>.apk
make dmg        # macOS -> outputs/write_lao-macos-<版本>.dmg
```

Windows、Linux 的打包说明见主文档 [README.md](README.md) 的
"Build a Release for Any Platform" 一节。

## 已知的联网限制

应用本身完全离线，以下功能在中国大陆受网络限制，但**不影响正常使用**：

- **崩溃报告（Sentry）**：应用会尝试向 `us.sentry.io` 发送崩溃日志。该服务在大陆
  不可达，请求会静默失败，不影响应用功能。
- **内购（IAP）**：仅存在于商店版本。开源构建已解锁全部内容，无需内购。
