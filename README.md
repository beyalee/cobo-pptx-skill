# cobo-customer-solution-deck

> Cobo 对客方案 PPT（.pptx）技能，适用于 Claude Code / Codex。
> 让 Claude 按 2026-09 台湾数娱版定下的叙事结构、文案规则、产品口径和视觉系统，做或改写 MPC / Payment 的客户 deck。

作者：Lucas（口径负责人）· 维护：@beyalee

---

## 安装

```bash
git clone https://github.com/beyalee/cobo-ppt-pptx-skill ~/.claude/skills/cobo-customer-solution-deck
```

### 依赖

```bash
pip install python-pptx
```

```bash
brew install --cask libreoffice
```

LibreOffice 用来把每页渲染成图做 QA、导出 PDF。

### 更新

这个 skill **不会自动更新**。Claude 每次会话第一次调用它时会比对版本，有新版会提醒你，但不会替你更新。

```bash
git -C ~/.claude/skills/cobo-customer-solution-deck pull
```

---

## 怎么用

直接说需求即可，例如：

```
帮我给一家越南的支付公司做一份 Cobo Payment 的方案 PPT，简体中文
```

```
把这份台湾数娱版改成英文，客户是新加坡的交易所 @deck.pptx
```

Claude 会：

1. 找母版（官方模板 skill 的 `reference.pptx`，或你给的一份 Cobo 对客 pptx）。**手边没有母版就先准备一份最近定稿的 Cobo 客户 deck**。
2. 先按页列出"页码 → 处理方式 → 理由"让你确认，再动手。
3. 改 pptx、逐页渲染检查，交付 pptx + pdf。

---

## 文件结构

```
cobo-customer-solution-deck/
├── SKILL.md                  # 主规则：叙事结构、文案规则、产品口径、视觉系统、制作流程
├── VERSION                   # 版本号 + 一句话说明
├── references/
│   └── market_tw.md          # 台湾市场用词表与说法
├── scripts/
│   ├── deck_components.py    # python-pptx 组件：卖点卡、Q&A、风险三档、痛点流程、对比表
│   └── check-update.sh       # 版本检查
└── agents/openai.yaml        # Codex 的展示配置
```

---

## 怎么一起维护

- **改产品口径、事实、用词**：改 `SKILL.md` 的"产品口径"或 `references/market_<市场>.md`。口径类改动先和 Lucas 对齐。
- **新增市场**：新建 `references/market_<市场>.md`，并在 `SKILL.md` 的"市场特例"里加一行。
- **新增组件**：加到 `scripts/deck_components.py`，在 `SKILL.md` 的"组件"一条里登记。
- **每次改完**：更新 `VERSION`（日期 + 一句话），这样同事那边会收到更新提醒。

```bash
cd ~/.claude/skills/cobo-customer-solution-deck
git checkout -b update-xxx
git commit -am "说明改了什么"
git push -u origin update-xxx
```

推送后在 GitHub 上开 Pull Request。小改动也可以直接推到 `main`。
