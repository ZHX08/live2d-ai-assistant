#!/usr/bin/env bash
set -euo pipefail

echo "=== Live2D AI 助手 · 项目初始化 ==="

# 1. 检查是否在项目根目录
if [ ! -f pubspec.yaml ]; then
  echo "❌ 请在项目根目录运行: cd live2d_ai_assistant && bash setup.sh"
  exit 1
fi

# 2. 创建 .env（如果不存在）
if [ ! -f .env ]; then
  cp .env.example .env
  echo "📝 已创建 .env 文件，请填入 API Keys"
  echo "   编辑 .env:"
  echo "     DEEPSEEK_API_KEY=sk-xxx"
  echo "     OPENAI_API_KEY=sk-xxx"
else
  echo "✅ .env 已存在"
fi

# 3. 先生成 flutter 原生配置（ios/android/linux/macos/windows）
#    放在临时目录，再移到项目根目录
TMP_DIR=$(mktemp -d)
echo "📦 生成原生平台配置..."
flutter create --org com.zhx --project-name live2d_ai_assistant "$TMP_DIR" > /dev/null 2>&1

# 只移动需要的原生目录
for dir in android ios linux macos windows web test; do
  if [ -d "$TMP_DIR/$dir" ] && [ ! -d "$dir" ]; then
    cp -r "$TMP_DIR/$dir" "./$dir"
    echo "   ✅ $dir/"
  fi
done

rm -rf "$TMP_DIR"

# 4. 安装依赖
echo "📦 安装依赖..."
flutter pub get

echo ""
echo "=== 🎉 初始化完成 ==="
echo ""
echo "下一步:"
echo "  1. 编辑 .env 填入 API Keys"
echo "  2. flutter run"
echo ""
