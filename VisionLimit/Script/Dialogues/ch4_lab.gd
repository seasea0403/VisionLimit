extends RefCounted

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "资料搜集得差不多了，我们整理一下目前的线索。",
		"choices": [
			{"text": "我再看看。", "next": "__exit__"},
			{"text": "好，你先说。", "next": "q1"},
		]
	},
	"q1": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "眼下这套「检测达标」的体系，是谁在维持它运转？",
		"choices": [
			{
				"text": "关联结构",
				"response": "晴野基金会以「环境检测服务委托」名义定期向正源环境检测付款。正源成立于2043年7月，两个月后收到第一笔款，法定代表人与临深集团关联实体指向同一人。委托方、检测方、背书方实际上很有可能是同一套关联结构。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q2",
				"condition": "clue_funds",
			},
			{
				"text": "资金关系不明",
				"response": "资金关系仍不明朗：付款记录是有，但直接关联尚待落实。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q2",
			},
		]
	},
	"q2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "2044年之后的实体档案，为什么没了？",
		"choices": [
			{
				"text": "档案缺失",
				"response": "苍屿症病例集中于2043年之后，而2044年起的实体档案以「数字化」为由停止留存，数字版同步加密处理。档案缺失的年份和病例最密集的年份高度重合。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q3",
				"condition": "clue_archive",
			},
			{
				"text": "属正常行政",
				"response": "数字化是普遍政策，未必有意。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q3",
			},
		]
	},
	"q3": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "那个被涂掉名字的人，是谁？",
		"choices": [
			{
				"text": "陈星河",
				"response": "工位牌修正液下可见「星河」二字，外业日志封面签名与量杯上的科室标注指向同一人——陈星河，水质监测组成员，曾在此任职，时间节点与关键档案年份重合，目前下落不明。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q4",
				"condition": "clue_person",
			},
			{
				"text": "情况不明",
				"response": "工位荒废已久，无从确认。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q4",
			},
		]
	},
	"q4": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "轮廓基本清楚了。现在差一环：把「排污」和「苍屿症」直接对应起来。那一环，很可能在郑和平的记忆海里。最后还剩一件事，要看你愿不愿意。几年前的记忆清洗并不彻底，你的记忆海中极有可能保留有郑和平的记忆，因此你眼前经常会出现郑和平的记忆碎片。我希望你能潜回你自己的记忆海，搜集证据。",
		"choices": [
			{"text": "……去我的操作工作台吧。", "next": "q5"},
		]
	},
	"q5": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "我多问一句，陈星河下落不明，郑和平昏迷至今，联络人已断联。掌握这些信息的人，基本都已经不在了。你有没有想过，为什么你现在还在这里？",
		"choices": [
			{
				"text": "巧合",
				"response": "我没有主动卷入这些事端，我的加入只是巧合而已。没必要为一个巧合大费周章。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"record_key": "ch4_shenyi_choice",
				"record_value": "A",
				"next": "",
			},
			{
				"text": "无害",
				"response": "在他们眼中，我的记忆已经被彻底清洗了，我是没有威胁的，所以我没有被「处理」。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"record_key": "ch4_shenyi_choice",
				"record_value": "B",
				"next": "",
			},
		]
	},
}
