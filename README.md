# Live2D AI 助手

Flutter 双端 APP，Live2D 虚拟角色 + 语音对话助手。

## 核心流程

按住说话 → ASR 识别 → LLM 回复 → TTS 语音合成 → Live2D 口型同步播放

## 状态机

idle → listening（侧耳）→ thinking（思考）→ speaking（口型同步）→ idle

## 使用

```bash
flutter pub get
# 配置 API Key（lib/core/api/api_config.dart）
flutter run
```

## 目录

```
lib/
├── main.dart                 # 入口
├── app/                      # APP 配置（路由/主题）
├── core/                     # 核心层
│   ├── api/                  # LLM / ASR / TTS 调用
│   ├── audio/                # 录音 / 播放
│   └── models/               # 数据模型 + 状态枚举
├── features/chat/            # 业务页面 + Provider
│   └── widgets/              # Live2D 画布 / 语音按钮 / 气泡
└── services/                 # Live2D 控制 / 对话编排
```
