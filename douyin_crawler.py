#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
douyin_crawler.py — 刷新 jaceyln wu 工作台的抖音爆款/热点数据
=====================================================================
作用：抓取抖音实时热榜，按 jaceyln wu 的赛道（姐妹/家庭/友情群像 · 生活Vlog
      · 知识成长 · 职场副业）做二次匹配，重新生成 douyin_data.js。
特点：只刷新「实时热榜」部分，保留人工精选的 2026 十大灵感选题 与 二创建议。

用法：
    python3 douyin_crawler.py
然后刷新/重启工作台（双击 index.html 或重启 Electron）即可看到新数据。

依赖：仅 Python 标准库（urllib / re / json）。
"""
import os, re, json, urllib.request, urllib.error, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "douyin_data.js")
ACCOUNT = "122498939"

# 关键词 -> (赛道角度, 二创建议) ，用于给刷新出的热点自动标注
ANGLE_MAP = [
    ("朋友", "友情群像", "拍和闺蜜/朋友的真实相处，白描式记录陪伴，结尾克制字幕"),
    ("青春", "友情群像", "翻老照片做多年对比混剪，旁白克制、靠画面讲故事"),
    ("你存在", "情感/回忆", "做『那些年一起疯的姐妹』混剪，按时间线串合照"),
    ("美食人格", "美食/生活", "和姐妹测各自的美食人格，快节奏对话剪辑"),
    ("歌名", "文案技巧", "用歌名做视频文案，做统一封面的系列栏目"),
    ("穿搭", "穿搭/氛围", "拍姐妹氛围感穿搭外景 vlog，重点拍群像镜头"),
    ("森系", "穿搭/氛围", "森系闺蜜装，氛围大于单品"),
    ("通勤", "生活", "拍早八通勤 vlog，生活感强、易复制"),
    ("投喂", "美食/生活", "拍被闺蜜/家人投喂的日常，结尾抛互动问句"),
    ("草原", "旅行/生活", "失联式放松 vlog，信号差是天然反差梗"),
    ("旅游", "旅行vlog", "小城漫游，记录 locals 的生活气"),
    ("城市", "旅行vlog", "反向安利自己的城市，群像 + 在地感"),
    ("心理学", "知识/心理学", "用『为什么被戳中』做知识向口播，配真实故事"),
    ("共情", "真实/共情", "拍普通人的闪光时刻，群像纪实风"),
    ("眼神", "镜头/情绪", "练一个眼神讲完一个故事的特写镜头"),
    ("舞", "挑战/舞蹈", "和姐妹合拍挑战，笨拙但快乐的群像版"),
    ("belike", "情感/改写", "性别反转 / 群像改写版，制造喜剧反差"),
    ("饭桌", "饭桌/家庭", "饭桌名场面家庭喜剧，固定机位"),
    ("妈妈", "群像/家庭", "拍和家人最普通的相处，白描式纪实"),
    ("童话", "情感", "拍姐妹间的承诺时刻，童话感滤镜 + 手写字幕"),
    ("放下", "成长/自我", "改编为『和过去的自己和解』，群像视角接力"),
    ("志无穷", "成长/自我", "姐妹轮流说『我曾经想成为的人 vs 现在的我』"),
]
DEFAULT = ("可改编", "结合你的群像/生活/知识/职场赛道挑一个情绪或实用角度切入二创")

def classify(topic):
    for kw, angle, idea in ANGLE_MAP:
        if kw in topic:
            return angle, idea
    return DEFAULT

def fetch_html(url, timeout=12):
    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "Accept-Language": "zh-CN,zh;q=0.9"
    })
    with urllib.request.urlopen(req, timeout=timeout) as r:
        raw = r.read()
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        return raw.decode("utf-8", "ignore")

def parse_uapis(html):
    """从 UApiPro 热榜页解析 [排名话题热度](url) 结构。"""
    topics = []
    # 形如： 01. [1长鑫科技上市31140.1万](https://...)
    pat = re.compile(r'^\s*(\d+)\.\s*\[(.+?)\]\(https?://', re.M)
    for m in pat.finditer(html):
        rank = int(m.group(1))
        inner = m.group(2)  # 例如 "1长鑫科技上市31140.1万"
        # 拆分：前导数字(排名) + 中文话题 + 末尾热度
        mm = re.match(r'^(\d+)([\u4e00-\u9fffA-Za-z·，。、！？~_]+?)(\d[\d.]*(?:万)?)\s*$', inner)
        if mm:
            topic = mm.group(2)
            heat = mm.group(3) + ("万" if not mm.group(3).endswith("万") else "")
        else:
            topic = re.sub(r'^\d+', '', inner)
            heat = ""
        topics.append((rank, topic.strip(), heat))
    return topics

def try_sources():
    sources = [
        "https://uapis.cn/hotboard/douyin",
        "https://www.abangshou.com/tools/douyin.html",
        "https://www.rddh.cn/trending/douyin",
    ]
    for url in sources:
        try:
            html = fetch_html(url)
            topics = parse_uapis(html)
            if topics:
                return topics
        except Exception as e:
            print(f"  · 源 {url} 失败：{e}")
    return []

def load_existing():
    """读取现有 douyin_data.js，保留静态部分（灵感选题/二创建议）。"""
    try:
        with open(OUT, "r", encoding="utf-8") as f:
            txt = f.read()
        themes = re.search(r'themes2026:\s*(\[.*?\]),\s*\n\s*remixIdeas', txt, re.S)
        remix = re.search(r'remixIdeas:\s*(\[.*?\])\s*\n\};', txt, re.S)
        return (
            json.loads(themes.group(1)) if themes else [],
            json.loads(remix.group(1)) if remix else [],
        )
    except Exception:
        return [], []

def main():
    print("▶ 抓取抖音实时热榜 ...")
    raw = try_sources()
    if not raw:
        print("✗ 所有数据源暂不可达，保留现有 douyin_data.js 不变。")
        print("  你可以稍后重跑本脚本，或手动在 douyin_data.js 里更新 hotTopics。")
        return

    themes, remix = load_existing()
    hot = []
    for rank, topic, heat in raw:
        angle, idea = classify(topic)
        hot.append({"rank": rank, "topic": topic, "heat": heat,
                    "angle": angle, "idea": idea})

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    block = {
        "account": ACCOUNT,
        "updated": now,
        "source": "抖音热榜(实时) + 新榜《2026创作指南》十大灵感选题",
        "note": "以下热点已按 jaceyln wu 的赛道（姐妹/家庭/友情群像 · 生活Vlog · 知识成长 · 职场副业）做二次匹配与二创角度标注。",
        "hotTopics": hot,
        "themes2026": themes,
        "remixIdeas": remix,
    }
    js = "// 本文件由 douyin_crawler.py 自动生成，请勿手工大改 hotTopics 部分。\n"
    js += "window.DOUYIN_DATA = " + json.dumps(block, ensure_ascii=False, indent=2) + ";\n"
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(js)
    print(f"✓ 已更新 {OUT}")
    print(f"  热榜条目：{len(hot)} 条 ｜ 更新时间：{now}")
    print(f"  保留静态内容：十大灵感选题 {len(themes)} 条，二创建议 {len(remix)} 条")

if __name__ == "__main__":
    main()
