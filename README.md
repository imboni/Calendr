# Calendr 中国版

我在 [pakerwreah/Calendr](https://github.com/pakerwreah/Calendr) 的基础上维护本中国版，面向中文用户补充农历、节假日与二十四节气。本仓库并非原作者的官方发行，相关改动亦未提交至上游。

[![release](https://img.shields.io/github/v/release/imboni/Calendr?label=Latest%20release)](https://github.com/imboni/Calendr/releases/latest)
[![homebrew](https://img.shields.io/badge/Homebrew_cask-gray?logo=homebrew&logoColor=ffdd00)](https://github.com/imboni/Calendr/blob/master/Casks/calendr.rb)

- **原作者：** [Carlos Enumo (pakerwreah)](https://github.com/pakerwreah)
- **原项目：** https://github.com/pakerwreah/Calendr
- **中国版：** https://github.com/imboni/Calendr

原作以 MIT 许可证发布。本仓库保留原版权声明。如需支持原作，请前往 [原仓库](https://github.com/pakerwreah/Calendr) 或 [Buy Me a Coffee](https://buymeacoffee.com/pakerwreah)。

## 安装

### GitHub Release

从 [Releases](https://github.com/imboni/Calendr/releases/latest) 下载 `Calendr.zip`，将 `Calendr.app` 拖入「应用程序」。首次打开若被拦截，可在 Finder 中右键选择「打开」，或执行：

```bash
xattr -cr /Applications/Calendr.app
```

应用内检查更新会读取本仓库的最新 Release。

### Homebrew

```bash
brew tap imboni/calendr https://github.com/imboni/Calendr
brew install --cask calendr
```

## 界面

<img width="360" src="resources/screenshot.png" alt="Calendr 中国版：月视图中的农历、节假日与节气" />

## 相对原作的改动

- 月视图日期格显示农历；每月初一以农历月份名标示
- 可显示中国大陆节假日名称，法定休息日辅以浅色底纹
- 二十四节气按北京时间计算，仅标注于当日
- 菜单栏日期可附带农历
- 点击标题年份选择年份，点击日期选择月份；选年时左右箭头按 12 年翻页
- 设置中可分别开关农历、节假日与节气；全部关闭时，格子布局与原作一致

上述选项默认开启。

## 版本与发布

版本号为 `MARKETING_VERSION`（当前 1.25.0）。GitHub Release 名称为 `v` 前缀，须与应用内版本一致（例如 `v1.25.0`），以便应用内检查更新。

发布流程：

1. 同步更新 `assemble.env` 与 Xcode 工程中的 `MARKETING_VERSION`
2. 打 tag 并推送：`git tag v1.25.0 && git push origin v1.25.0`
3. GitHub Actions `Release` 工作流会构建 `Calendr.app`、上传 `Calendr.zip`，并更新 `Casks/calendr.rb` 的版本与校验和

请勿将中国版改动向上游提交。

## 原作功能

[Calendr](https://github.com/pakerwreah/Calendr) 是一款 macOS 菜单栏日历。以下功能来自原作。

### 自然语言新建事件

在标题中一并输入日期、时间、时长、全天或日历指示，Calendr 会在输入时高亮已识别内容，并同步更新事件字段；保存时这些指示会从标题中移除。

示例：

`Pickleball with Tom next Friday from 10 to 12 /sport`

- 日期：`today`、`tomorrow`、`yesterday`、`in a week`、`in 3 days`、`on Friday`、`next Friday`、`August 12`
- 时间：`at 14`、`at 2pm`、`at noon`、`tomorrow morning`、`from 10 to 12`、`at 22 until 1`
- 相对开始与时长：`in 2 hours`、`for 30 minutes`、`for 2 hours`、`for 4 days`
- 全天：`all day`、`full day`
- 日历：以 `/` 后接日历名称片段，如 `/sport`，进行模糊匹配

目前支持英语与捷克语指示。解析器随 Calendr 的首选语言自动选择；其他语言仍可选用英语解析器。该功能可在设置中开关，英语与捷克语环境下默认开启。数字日期顺序遵循当前区域设置；标题的首个词始终保留为事件名称。

<img width="500" src="resources/smart-event-entry.png" alt="自然语言新建事件：日期、时间与日历指示高亮" />

### 菜单栏显示多个时区

格式：

`HH:mm | HH:mm@GMT+2 'LT' | HH:mm@GMT-3 'BR'`

结果：

`15:00 | 17:00 LT | 12:00 BR`

### URL Scheme 打开指定日期

说明见原项目：https://github.com/pakerwreah/Calendr/issues/314

| 日期 | 编码后的 URL |
| --- | --- |
| `december` | `calendr://date/december`（默认当前日与年） |
| `feb 10 2025` | `calendr://date/feb%2010%202025` |
| `2nd of September 2025` | `calendr://date/2nd%20of%20September%202025` |

相对日期仅有限支持 `today`、`yesterday`、`tomorrow`，不支持 `next week`、`last month` 等。此限制来自 `NSDataDetector`。
