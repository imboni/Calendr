import Foundation

// Real 2027 annual notice and corresponding feed, retrieved 2026-11-10.
// https://www.gov.cn/zhengce/zhengceku/202611/content_7085102.htm
// Future-year tests deliberately reuse these dates as SYNTHETIC fixtures, not predictions.
enum MainlandHolidayFixtures {
    static let feed = #"""
{"$schema":"https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/schema.json","$id":"https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/2027.json","year":2027,"papers":["https://www.gov.cn/zhengce/zhengceku/202611/content_7085102.htm"],"days":[{"name":"元旦","date":"2027-01-01","isOffDay":true},{"name":"元旦","date":"2027-01-02","isOffDay":true},{"name":"元旦","date":"2027-01-03","isOffDay":true},{"name":"春节","date":"2027-01-31","isOffDay":false},{"name":"春节","date":"2027-02-05","isOffDay":true},{"name":"春节","date":"2027-02-06","isOffDay":true},{"name":"春节","date":"2027-02-07","isOffDay":true},{"name":"春节","date":"2027-02-08","isOffDay":true},{"name":"春节","date":"2027-02-09","isOffDay":true},{"name":"春节","date":"2027-02-10","isOffDay":true},{"name":"春节","date":"2027-02-11","isOffDay":true},{"name":"春节","date":"2027-02-12","isOffDay":true},{"name":"春节","date":"2027-02-13","isOffDay":true},{"name":"春节","date":"2027-02-14","isOffDay":false},{"name":"清明节","date":"2027-04-03","isOffDay":true},{"name":"清明节","date":"2027-04-04","isOffDay":true},{"name":"清明节","date":"2027-04-05","isOffDay":true},{"name":"劳动节","date":"2027-05-01","isOffDay":true},{"name":"劳动节","date":"2027-05-02","isOffDay":true},{"name":"劳动节","date":"2027-05-03","isOffDay":true},{"name":"劳动节","date":"2027-05-04","isOffDay":true},{"name":"劳动节","date":"2027-05-05","isOffDay":true},{"name":"劳动节","date":"2027-05-08","isOffDay":false},{"name":"端午节","date":"2027-06-09","isOffDay":true},{"name":"中秋节","date":"2027-09-15","isOffDay":true},{"name":"国庆节","date":"2027-09-26","isOffDay":false},{"name":"国庆节","date":"2027-10-01","isOffDay":true},{"name":"国庆节","date":"2027-10-02","isOffDay":true},{"name":"国庆节","date":"2027-10-03","isOffDay":true},{"name":"国庆节","date":"2027-10-04","isOffDay":true},{"name":"国庆节","date":"2027-10-05","isOffDay":true},{"name":"国庆节","date":"2027-10-06","isOffDay":true},{"name":"国庆节","date":"2027-10-07","isOffDay":true},{"name":"国庆节","date":"2027-10-09","isOffDay":false}]}
"""#
    static let notice = #"""
<h1>国务院办公厅关于2027年部分节假日安排的通知</h1>
<p>一、元旦：1月1日（周五）至3日（周日）放假，共3天。</p>
<p>二、春节：2月5日（农历除夕、周五）至13日（农历正月初八、周六）放假调休，共9天。1月31日（周日）、2月14日（周日）上班。</p>
<p>三、清明节：4月3日（周六）至5日（周一）放假，共3天。</p>
<p>四、劳动节：5月1日（周六）至5日（周三）放假调休，共5天。5月8日（周六）上班。</p>
<p>五、端午节：6月9日（周三）放假，共1天。</p>
<p>六、中秋节：9月15日（周三）放假，共1天。</p>
<p>七、国庆节：10月1日（周五）至7日（周四）放假调休，共7天。9月26日（周日）、10月9日（周六）上班。</p>
"""#
    static func feedData(year: Int = 2027) -> Data {
        Data(feed.replacingOccurrences(of: "2027", with: String(year)).utf8)
    }
    static func noticeData(year: Int = 2027) -> Data {
        Data(notice.replacingOccurrences(of: "2027", with: String(year)).utf8)
    }
    static let combinedFeed = #"""
{"$schema":"https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/schema.json","$id":"https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/2025.json","year":2025,"papers":["https://www.gov.cn/zhengce/zhengceku/202411/content_6986383.htm"],"days":[{"name":"元旦","date":"2025-01-01","isOffDay":true},{"name":"春节","date":"2025-01-26","isOffDay":false},{"name":"春节","date":"2025-01-28","isOffDay":true},{"name":"春节","date":"2025-01-29","isOffDay":true},{"name":"春节","date":"2025-01-30","isOffDay":true},{"name":"春节","date":"2025-01-31","isOffDay":true},{"name":"春节","date":"2025-02-01","isOffDay":true},{"name":"春节","date":"2025-02-02","isOffDay":true},{"name":"春节","date":"2025-02-03","isOffDay":true},{"name":"春节","date":"2025-02-04","isOffDay":true},{"name":"春节","date":"2025-02-08","isOffDay":false},{"name":"清明节","date":"2025-04-04","isOffDay":true},{"name":"清明节","date":"2025-04-05","isOffDay":true},{"name":"清明节","date":"2025-04-06","isOffDay":true},{"name":"劳动节","date":"2025-04-27","isOffDay":false},{"name":"劳动节","date":"2025-05-01","isOffDay":true},{"name":"劳动节","date":"2025-05-02","isOffDay":true},{"name":"劳动节","date":"2025-05-03","isOffDay":true},{"name":"劳动节","date":"2025-05-04","isOffDay":true},{"name":"劳动节","date":"2025-05-05","isOffDay":true},{"name":"端午节","date":"2025-05-31","isOffDay":true},{"name":"端午节","date":"2025-06-01","isOffDay":true},{"name":"端午节","date":"2025-06-02","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-09-28","isOffDay":false},{"name":"国庆节、中秋节","date":"2025-10-01","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-02","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-03","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-04","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-05","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-06","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-07","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-08","isOffDay":true},{"name":"国庆节、中秋节","date":"2025-10-11","isOffDay":false}]}
"""#
    static let combinedNotice = #"""
<h1>国务院办公厅关于2025年部分节假日安排的通知</h1>
<p>一、元旦：1月1日（周三）放假1天，不调休。</p>
<p>二、春节：1月28日（农历除夕、周二）至2月4日（农历正月初七、周二）放假调休，共8天。1月26日（周日）、2月8日（周六）上班。</p>
<p>三、清明节：4月4日（周五）至6日（周日）放假，共3天。</p>
<p>四、劳动节：5月1日（周四）至5日（周一）放假调休，共5天。4月27日（周日）上班。</p>
<p>五、端午节：5月31日（周六）至6月2日（周一）放假，共3天。</p>
<p>六、国庆节、中秋节：10月1日（周三）至8日（周三）放假调休，共8天。9月28日（周日）、10月11日（周六）上班。</p>
"""#
}
