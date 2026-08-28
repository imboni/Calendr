# Calendr 中国版

这是基于 [pakerwreah/Calendr](https://github.com/pakerwreah/Calendr) 完善的**中国版**，由 [Boni](https://github.com/imboni) 维护。

它不是原作者的官方项目，也没有向原仓库提交这些改动。菜单栏日历的主体功能来自原作；本仓库在此基础上补了农历、中国大陆节假日和二十四节气。

**原作者：** [Carlos Enumo (pakerwreah)](https://github.com/pakerwreah)  
**原项目：** https://github.com/pakerwreah/Calendr  
**中国版：** https://github.com/imboni/Calendr

原作是 MIT 许可。本仓库保留原版权声明；中国版改动的版权归 Boni。支持原作者请看 [原项目](https://github.com/pakerwreah/Calendr) 和 [Buy Me a Coffee](https://buymeacoffee.com/pakerwreah)。

## 中国版增加了什么

- 日历格子显示农历（初一显示月份名）
- 格子上可显示中国大陆节假日名称，法定休息日有浅色底
- 二十四节气按北京时间计算，只标在当天
- 菜单栏日期可附带农历
- 设置里可分别开关农历、节假日、节气；全关时格子回到原作布局

这些选项默认打开，可在设置里关掉。

## Menu bar calendar for macOS

Original app by [pakerwreah](https://github.com/pakerwreah/Calendr):

<table>
<tr>
  <td>
    <img width=350 src="resources/screenshot.png" title="Calendr" />
    <img valign='top' width=170 src='https://github.com/pakerwreah/Calendr/assets/803954/8b3ebb0f-52ad-461c-91c3-7b4d2646712e' />
    <img valign='top' width=150 src='https://github.com/pakerwreah/Calendr/assets/803954/8e8d342d-9be5-4bad-b741-875cc407ec1a' />
  </td>
</tr>
</table>

## Natural-language event entry

Create events faster by typing the title together with optional date, time, duration, all-day, and calendar instructions. Calendr highlights recognized instructions while you type, immediately updates the event fields, and removes the instructions from the saved event title.

For example:

`Pickleball with Tom next Friday from 10 to 12 /sport`

- Dates: `today`, `tomorrow`, `yesterday`, `in a week`, `in 3 days`, `on Friday`, `at Friday`, `next Friday`, or `August 12`
- Times: `at 14`, `at 2pm`, `at noon`, `tomorrow morning`, `from 10 to 12`, or `at 22 until 1`
- Relative starts and durations: `in 2 hours`, `for 30 minutes`, `for 2 hours`, or `for 4 days`
- All-day events: `all day` or `full day`
- Calendars: add `/` followed by part of a calendar name, such as `/sport`, to fuzzy-match and select it

English and Czech instructions are supported. The parser follows Calendr's preferred localization automatically. Unsupported localizations can still opt in to the English parser.

The feature can be enabled or disabled in Settings and defaults to enabled for English and Czech localizations. Numeric dates follow the date order configured by the active locale, and the first word is always preserved as event title text.

<table>
<tr>
  <td>
    <img width="500" src="resources/smart-event-entry.png" alt="Natural-language event entry with highlighted date, time, and calendar instructions" />
  </td>
</tr>
</table>

## Hidden features

### Display multiple timezones in the menu bar
- Format
`HH:mm | HH:mm@GMT+2 'LT' | HH:mm@GMT-3 'BR'`
- Result
`15:00 | 17:00 LT | 12:00 BR`

### Open date with a URL scheme

See the original write-up: https://github.com/pakerwreah/Calendr/issues/314

date|encoded
--|--
`december`|`calendr://date/december` (defaults to current date and year)
`feb 10 2025`|`calendr://date/feb%2010%202025`
`2nd of September 2025`|`calendr://date/2nd%20of%20September%202025`

It has limited support to relative dates like: `today`, `yesterday`, `tomorrow` but will not work with `next week`, `last month`, etc.

That's how `NSDataDetector` works ¯\\_\(ツ\)\_/¯
