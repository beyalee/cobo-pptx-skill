# 把做好的 deck 变成 Google 幻灯片（可共享编辑的 URL）

pptx 交付出去只能单机改。客户或同事要一起编辑、要一个能发出去的链接时，把 deck 传成 Cobo Google 账号下的原生 Google 幻灯片。

## 什么时候问

deck 交付完、QA 过了之后，**主动问一次**用户：

> 需要帮你把这份 deck 传成 Google 幻灯片吗？会在你 Cobo 账号下生成一个可编辑的链接，方便发给同事一起改。
> - yes 做
> - no 不做

- 用户说 yes → 按下面的步骤做。
- 用户说 no → 到此为止，不要再问第二次。
- **分享权限永远不要碰**。传完把链接给用户，让他自己在「共享」里决定给谁、给什么权限。

## 前置

- Claude in Chrome 已连接，且 Chrome 里登录的是 Cobo Google 账号（`list_connected_browsers` 确认有浏览器）。
- 文件要小于 10 MB（`file_upload` 的上限）。从 Google Slides 导出的母版会带 7 MB 左右的内嵌字体，先做一份去掉内嵌字体的上传版：
  - 解压 pptx → 删 `ppt/fonts/` → 删 `presentation.xml` 里的 `<p:embeddedFontLst>` → 删 `ppt/_rels/presentation.xml.rels` 里指向 `fonts/` 的关系 → 删 `[Content_Types].xml` 里 `fntdata` 的 Default 和 `/ppt/fonts/` 的 Override → 重新打包。
  - 传回 Google Slides 不需要内嵌字体，Poppins 和 Noto Sans TC/SC 它自己有。删完渲染一遍确认没变化。

## 走得通的上传方法

**不要试这几条，全都不通**：系统文件选择器（是操作系统窗口，点不到）；本地起 HTTP 服务让页面 fetch（docs.google.com 的 CSP 直接挡掉，页面会报 `Failed to fetch`）；对 Drive 页面派发合成的 drop 事件（Google 不认）。

能跑通的是「注入暂存输入框 + 扩展直接写盘上的文件 + 跨 realm 搬运」：

1. `navigate` 到 `https://docs.google.com/presentation/u/0/`，等 7 秒。
2. 点「最近的演示文稿」那一行最右的**文件夹图标**打开文件选择器，再点**「上传」**标签。等它把 Picker 的 iframe 加载出来。
3. 用 `javascript_tool` 在**顶层文档**注入一个可见的暂存输入框：
   ```js
   let el=document.getElementById('cuStage');
   if(!el){el=document.createElement('input'); el.type='file'; el.id='cuStage';
     el.setAttribute('aria-label','cuStage');
     el.style.cssText='position:fixed;left:10px;bottom:10px;z-index:2147483647;width:300px;height:34px;background:#fff';
     document.documentElement.appendChild(el);}
   ```
4. `find` 查 "cuStage file input" 拿 ref，用 `file_upload` 把本地 pptx 塞进去。扩展直接读磁盘，不走页面网络，所以躲开了 CSP。
5. 用 `javascript_tool` 把文件搬进 Picker iframe 的真实输入框并触发它：
   ```js
   const f=document.getElementById('cuStage').files[0];
   let doc=null;
   for(const fr of [...document.querySelectorAll('iframe')]){
     try{const d=fr.contentDocument; if(d&&d.querySelector('input[type=file]')){doc=d;break;}}catch(e){}
   }
   const inp=doc.querySelector('input[type=file]');
   const dt=new DataTransfer(); dt.items.add(f);
   inp.files=dt.files;
   inp.dispatchEvent(new Event('change',{bubbles:true}));
   ```
   **坑**：如果赋值后 `inp.files.length` 还是 0，是跨 realm 的问题——改用 iframe 自己的构造器（`doc.defaultView.DataTransfer`、`doc.defaultView.File`）重建 File 再赋值。
6. 上传开始，Google 自动把 pptx 转成原生幻灯片并打开，地址栏变成 `docs.google.com/presentation/d/<id>/edit`。
7. 收尾：
   - 删掉暂存输入框 `document.getElementById('cuStage').remove()`。
   - 文件名会带上传版的后缀，点左上角标题框改成正式名字（等编辑器完全加载再点，太早点会落到画布上选中图形）。

## 验收

不要靠肉眼翻 Slides。`navigate` 到 `https://docs.google.com/presentation/d/<id>/export/pdf`，Chrome 会把 PDF 下载到用户的下载目录，再用 pymupdf 逐页转图，跟 Keynote 渲染的那版对一遍。确认过再把 PDF 挪进 `deliverables/<主题>/render/`，别留在下载目录。

常见的转换差异：个别中文字距会微微变宽（Google 替换字体导致），不影响阅读；项目符号可能按母版样式重新出现。版式、颜色、图形、图片一般完整保留——因为 Cobo 母版本来就是 Google 幻灯片做的。

## 交付之后

提醒用户：**来源变了**。以后在 Slides 上改，本地 pptx 就是旧的。要再让 Claude 改，流程是从 Slides 导出 pptx → 改 → 按上面的步骤再传一次。
