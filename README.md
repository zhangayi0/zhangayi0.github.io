# 静态知识库（索引 + 单页浏览）

纯前端静态页 + Python 索引脚本，适合本地查阅或托管到 **GitHub Pages**。

## 仓库结构

| 路径 | 说明 |
|------|------|
| `build_index.py` | 扫描目录并生成 `index.json` |
| `docs/index.html` | 单页前端（Marked + 纯 JS），与知识库同级部署 |
| `docs/*/…` | 一级子文件夹为分类，内含 `.md` / `.html` |
| `docs/index.json` | 索引（可本地生成，或由 CI 在部署时生成） |
| `docs/index.inline.js` | 与索引同内容的 `window.__KB_INDEX__`，便于 `file://` 打开首页时加载目录（由 `build_index.py` 一并生成） |

前端入口请在 **`docs/index.html`**（根目录不再保留副本，避免与 GitHub Pages 不同步）。

## 目录约定

知识库**根目录**（此处为 `docs/`）下，只有**一级子文件夹**会被列为分类；每个子文件夹内可放任意数量的 `.md`、`.html`（支持子目录，路径写入 `index.json` 的 `path`）。

页面通过 `fetch("./index.json")` 加载正文，请用 **HTTP(S)** 打开（不要用 `file://`）。

若仅用 `file://` 打开 `index.html`，浏览器通常会拦截对 `index.json` 的 `fetch`；构建脚本会同时生成 **`index.inline.js`**（由 `index.html` 以 `<script src>` 引入），用于在本地文件协议下加载**目录与标签索引**。打开具体 `.md` / `.html` 正文时，多数浏览器仍会拦截 `fetch`，此时请改用本地 HTTP 服务。

## 标签写法

- **Markdown**：文件**前 10 行**内单独一行：`tags: JavaScript, 教程`（逗号分隔）
- **HTML**：文件前部注释：`<!-- tags: JavaScript, 教程 -->`

未写标签则为 `[]`。

## 本地生成索引与预览

在仓库根目录执行：

```bash
python build_index.py docs
```

在 `docs` 目录启动静态服务：

```bash
cd docs
python -m http.server 8080
```

浏览器打开：`http://127.0.0.1:8080/index.html`

（Windows 可用 PowerShell 执行上述命令；也可用 VS Code Live Server，打开 `docs/index.html` 所在目录。）

## 部署到 GitHub Pages

1. 在 GitHub 新建仓库，将本仓库推送上去。
2. 打开 **Settings → Pages**。
3. **Build and deployment** 里 **Source** 选择 **GitHub Actions**（不要选「Deploy from a branch」除非你改用分支目录）。
4. 推送至 **`main`** 或 **`master`** 分支后，工作流 **Deploy GitHub Pages** 会：
   - 运行 `python build_index.py docs` 生成最新的 `index.json`；
   - 将 **`docs/` 整个目录**发布为站点根目录。
5. 站点地址一般为：`https://<你的用户名>.github.io/<仓库名>/`  
   打开：`https://<你的用户名>.github.io/<仓库名>/index.html`（多数情况下 `/index.html` 可省略）

**说明：** 页面使用相对路径加载 `index.json` 与正文，在项目子路径（`/仓库名/`）下也可正常工作。正文中的 Markdown 由 CDN 加载 **marked.js**，需要联网。

### 首次启用 Pages 的常见提示

- 若 Actions 报错权限：在仓库 **Settings → Actions → General** 中允许 Workflow 读写。
- 部署完成后若 404：等待 1～2 分钟再刷新；确认默认分支与工作流里的分支名一致。

## 路由说明

- 文档：`#/文件夹名/文件名`
- 标签：`#/tag/标签名`

支持浏览器前进、后退（`hashchange`）。

## 推送到 GitHub（命令示例）

```bash
git init
git add .
git commit -m "Initial commit: static knowledge base"
git branch -M main
git remote add origin https://github.com/<用户名>/<仓库名>.git
git push -u origin main
```

若默认分支为 `master`，工作流已同时监听 `main` 与 `master`。
