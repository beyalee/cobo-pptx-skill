# Cobo 客户方案 PPT skill

由 Lucas 整理，风格基准是 2026-09 定稿的台湾数娱版。

跟 Claude 说「帮我给 XX 客户做一份 MPC / Payment 方案 PPT」，它会套用 Cobo 官方模板，按定稿的结构和口径直接做出 `.pptx`。支持简体、繁体、英文。

---

## 安装

```bash
git clone https://github.com/beyalee/cobo-pptx-skill ~/.claude/skills/cobo-customer-solution-deck
```

装一次依赖（Claude 用 python-pptx 改 PPT，用 PyMuPDF 把每页转成图片检查排版；转换靠 Mac 自带的 Keynote，不用另装软件）：

```bash
pip install python-pptx pymupdf
```

---

## 更新

用这行代码更新：

```bash
git -C ~/.claude/skills/cobo-customer-solution-deck pull
```

不更新就会停留在安装那天的版本。有新版时，Claude 在你每次对话第一次用这个 skill 时会在对话里提醒你，要不要更新由你决定。也可以用这行代码手动检查：

```bash
bash ~/.claude/skills/cobo-customer-solution-deck/scripts/check-update.sh
```

---

## 使用方式

### 1. 从 0 搭建一份 PPT

```
帮我给一家越南支付公司做一份 Cobo Payment 方案 PPT，简体中文
```

```
根据这份客户需求和会议纪要，做一份 MPC 方案 PPT @客户需求.docx
```

Claude 会先按页列出修改清单给你确认，确认后再做，最后交付 `.pptx`。

### 2. 语言切换

```
把这份台湾数娱版改成英文，客户是新加坡的交易所 @deck.pptx
```

```
把这份中文的 HTML 做成一份英文 PPT @tron_u.html
```

不是逐字翻译，用词按目标语言的口径重写。

### 3. 用词本地化

```
把这份大陆用语的方案改成台湾用语，受众是台湾游戏平台 @deck.pptx
```

```
按大陆用语改一版 MPC 方案，受众是游戏平台老板 @deck.pptx
```

同一个产品，台湾讲「網銀平台」，大陆讲「结算平台」。

---

## 生成效果

- Cobo 母版：白底内容页、蓝色页脚条，章节页和封面蓝底
- 主蓝高亮 `#0024A1`：用于标题、卖点名、关键信息条
- 标题写主张句：「出款安全：想偷錢，要同時突破好幾道關卡」，而不是「風控管理流程」
- 卖点卡、Q&A、风险三档、痛点流程、对比表：统一组件，扁平无装饰
- 主讲页不出现术语：TSS、Vault、Webhook 这类词只放附录
- 可编辑：输出是真正的 `.pptx`，不是图片拼贴

### deck 按客户的问题排，不按产品功能排

```
封面        场景 + 产品分工
关于 Cobo    1 页公司介绍 + 1 页牌照与品管
一、<客户场景>｜<产品>
            痛点 → 定位与卖点 → 分工 → vs 替代方案 → 机制 → 信任 → 能力细节 → 案例
二、…       同上
下一步       「帶上你的場景，45 分鐘給你一張方案圖」
附录        API、对接流程、权限与签核等技术页
```

两个产品时正文约 28 页，附录另算。每章都能单独讲，销售打法是先 qualify、主讲一个产品。

---

## 文件结构

```
cobo-customer-solution-deck/
├── SKILL.md                  # 主规则：叙事结构、文案规则、产品口径、视觉系统、制作流程（Claude 读取）
├── VERSION                   # 版本号 + 一句话说明
├── assets/
│   └── reference.pptx        # Cobo 官方模板（台湾数娱版），做 deck 的母版
├── references/
│   └── market_tw.md          # 台湾市场用词表与说法
├── scripts/
│   ├── deck_components.py    # python-pptx 组件：卖点卡、Q&A、风险三档、痛点流程、对比表
│   ├── render.sh             # 用 Keynote 把 pptx 渲染成 PDF + 每页图片，做 QA
│   ├── pdf2png.py            # PDF 逐页转图片 + 缩略图总览
│   └── check-update.sh       # 版本检查
└── agents/openai.yaml        # Codex 展示配置
```

---

## 维护

1. 口径类改动（产品口径、事实、用词）先和 Lucas 或 Beya 对齐，再改 `SKILL.md` 的「产品口径」或 `references/market_<市场>.md`。
2. 新增市场：新建 `references/market_<市场>.md`，并在 `SKILL.md` 的「市场特例」里加一行。
3. 新增组件：加到 `scripts/deck_components.py`，并在 `SKILL.md` 的「组件」一条里登记。
4. 每次改完都更新 `VERSION`（日期 + 一句话），同事那边才会收到更新提醒。
