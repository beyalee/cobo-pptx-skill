# cobo-customer-solution-deck

> Cobo 对客方案 PPT 技能，适用于 Claude Code。
> 一行命令安装，说出客户和产品，Claude 按 Cobo 定稿的叙事结构、文案规则和视觉风格，生成可直接编辑的 `.pptx` 方案 deck。

支持**简体中文、繁体中文、英文**，风格基准是 2026-09 定稿的台湾数娱版，由 Lucas 整理。

---

## 安装

```bash
git clone https://github.com/beyalee/cobo-ppt-pptx-skill ~/.claude/skills/cobo-customer-solution-deck
```

安装后 Claude Code 会自动识别，无需重启。

### 更新

> **这个 skill 不会自动更新。** 不 pull 就会一直停在你安装那天的版本。

```bash
git -C ~/.claude/skills/cobo-customer-solution-deck pull
```

pull 完**不用重启** Claude Code，当前会话就生效。

Claude 每次被调用会自动比对本地与远端版本，有新版会提醒你 —— 但**不会替你更新**，要不要 pull 由你决定。想手动查：

```bash
bash ~/.claude/skills/cobo-customer-solution-deck/scripts/check-update.sh
```

---

## 使用方式

**1. 描述客户和产品，或直接丢资料给它**，Claude 从零搭一份：

```
帮我给一家越南支付公司做一份 Cobo Payment 方案 PPT，简体中文
```

```
根据这份客户需求和会议纪要，做一份 MPC 方案 deck @客户需求.docx
```

**2. 语言切换** —— 中英互换、简繁互换。不是逐字翻译，用词按目标语言的口径重写：

```
把这份台湾数娱版改成英文，客户是新加坡的交易所 @deck.pptx
```

```
把这份简体版转成繁体 @deck.pptx
```

**3. 本地化** —— 换成当地客户听得懂的说法。同一个产品，台湾讲「網銀平台」，大陆讲「结算平台」：

```
按大陆用语改一版 MPC 方案，受众是游戏平台老板
```

Claude 会：
1. 找母版 —— **手边最好准备一份最近定稿的 Cobo 客户 deck**，没有母版它会先问你要
2. 按页列出「页码 → 处理方式 → 理由」让你确认 —— **这一步值得认真看**，删页、合并页、改事实都在这里定
3. 改 pptx，逐页渲染检查文字溢出、重叠
4. 交付 `.pptx`

---

## 生成效果

-  **Cobo 母版** — 白底内容页、蓝色页脚条，章节页和封面蓝底
-  **主蓝高亮** — `#0024A1`，用于标题、卖点名、关键信息条
-  **标题写主张句** — 「出款安全：想偷錢，要同時突破好幾道關卡」，而不是「風控管理流程」
-  **卖点卡、Q&A、风险三档、痛点流程、对比表** — 统一组件，扁平无装饰
-  **主讲页不出现术语** — TSS、Vault、Webhook 这类词只放附录
-  **可编辑** — 输出是真正的 `.pptx`，不是图片拼贴

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

两个产品时正文约 28 页，附录另算。**每章都能单独讲** —— 销售打法是先 qualify、主讲一个产品。

---

## 文件结构

```
cobo-customer-solution-deck/
├── SKILL.md                  # 主规则：叙事结构、文案规则、产品口径、视觉系统、制作流程（Claude 读取）
├── VERSION                   # 版本号 + 一句话说明
├── references/
│   └── market_tw.md          # 台湾市场用词表与说法
├── scripts/
│   ├── deck_components.py    # python-pptx 组件：卖点卡、Q&A、风险三档、痛点流程、对比表
│   └── check-update.sh       # 版本检查
└── agents/openai.yaml        # Codex 展示配置
```

---

## 依赖

- [Claude Code](https://claude.ai/code)（需登录 Anthropic 账户）
- python-pptx：`pip install python-pptx`
- 逐页渲染检查需要 LibreOffice：`brew install --cask libreoffice`

---

## 维护

改产品口径、事实或用词，编辑 `SKILL.md` 的「产品口径」或 `references/market_<市场>.md` —— **口径类改动先和 Lucas 对齐**。
新增市场，新建 `references/market_<市场>.md`，并在 `SKILL.md` 的「市场特例」里加一行。
新增组件，加到 `scripts/deck_components.py`，并在 `SKILL.md` 的「组件」一条里登记。

每次改完，更新 `VERSION`（日期 + 一句话），同事那边才会收到更新提醒。
