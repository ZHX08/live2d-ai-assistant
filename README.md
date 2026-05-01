# Live2D AI 助手

Flutter 双端 APP，Live2D 虚拟角色 + 语音对话助手。

## 核心流程

```
按住说话 → ASR 识别 → LLM 回复 → TTS 合成 → Live2D 口型同步播放
```

## 状态机

```
idle ➜ listening（侧耳倾听）➜ thinking（歪头思考）➜ speaking（口型同步）➜ idle
```

## 快速开始

```bash
# 1. 克隆项目
git clone git@github.com:ZHX08/live2d-ai-assistant.git
cd live2d-ai-assistant

# 2. 一键初始化（生成原生配置 + 安装依赖）
bash setup.sh

# 3. 填入 API Keys
#    编辑 .env 文件，按提示填写

# 4. 运行
flutter run
```

## 技术栈

| 层级 | 方案 |
|---|---|
| 框架 | Flutter 3.16+ / Dart 3.2+ |
| 状态管理 | Riverpod |
| LLM | DeepSeek Chat API（兼容 OpenAI 格式） |
| ASR | Whisper API |
| TTS | OpenAI TTS / Fish Audio |
| 录音 | record (AAC-LC) |
| 播放 | just_audio |
| Live2D | Cubism Native SDK（MethodChannel） |

## 目录结构

```
lib/
├── main.dart                 # 入口（初始化 API 配置）
├── app/                      # MaterialApp + 暗色主题
├── core/
│   ├── api/                  # LLM / ASR / TTS 客户端
│   ├── audio/                # 录音 / 播放
│   └── models/               # 对话消息 + Live2D 状态机
├── features/chat/            # 主页面 + Riverpod Provider
│   └── widgets/              # Live2D 画布 / 语音按钮 / 气泡
└── services/                 # Live2D 控制 / 对话编排
```

## 开发计划

- [ ] Phase 1 — 骨架运行 + API 闭环
- [ ] Phase 2 — 体验打磨（分段 TTS / 波形 / 持久化）
- [ ] Phase 3 — Live2D 角色集成（Cubism SDK）
- [ ] Phase 4 — 上架准备（错误处理 / 打包）
