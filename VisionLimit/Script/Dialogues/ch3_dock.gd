## 第三章·码头 —— 魏江复盘对话数据
## 三条线索（clue_price / clue_trace / clue_inspect）影响可选选项；最终两选一记录档案。

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "码头中有几件事不太对。我们对一遍。",
		"choices": [
			{"text": "我再走一圈。", "next": "__exit__"},
			{"text": "好，对一下。",  "next": "q1"},
		]
	},
	"q1": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "C-03海域的渔获情况是否正常？",
		"choices": [
			{
				"text": "明显异常",
				"response": "C-03区同规格定价不到A-02区的三成，但渔民自己说不吃这边的鱼。说明价格低不是因为别的，只是因为没人敢买。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q2",
				"condition": "clue_price",
			},
			{
				"text": "未见明显异常",
				"response": "不同海域作业条件不同，价差可解释。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q2",
			},
		]
	},
	"q2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "渔获溯源记录是否存在矛盾？",
		"choices": [
			{
				"text": "存在明显矛盾",
				"response": "CY-0887号船的溯源标签写着今天09:30入库；同一时刻，泊位告示牌上这艘船还在海上，预计明日返港。今天的鱼，来自一艘今天没有靠岸的船。渔获溯源系统并不可靠。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q3",
				"condition": "clue_trace",
			},
			{
				"text": "未见明显异常",
				"response": "标签格式规范，暂未发现明显问题。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q3",
			},
		]
	},
	"q3": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "环境检测的链条是否正常？",
		"choices": [
			{
				"text": "存在明显阻力",
				"response": "送检被以\"材料不足\"为由拒收——但谁认定的、依据什么、何时认定，全部空白。检测的阻力是出在哪个环节？",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q4",
				"condition": "clue_inspect",
			},
			{
				"text": "可能属正常程序",
				"response": "检测机构有自己的收件标准，未必出于外部压力。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q4",
			},
		]
	},
	"q4": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "差不多了，源头大概率是C-03海域的污染。要把这件事坐实，得拿到环保局的检测档案。\n渔民自己说了不吃C-03海域这些鱼，但却还在捕捞。你怎么看这件事？",
		"choices": [
			{
				"text": "没有选择",
				"response": "他们没得选。C-03海域的准入门槛低，只要有人收这片海域的鱼，就会有人继续捕捞。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"record_key": "ch3_dock_feeling",
				"record_value": "A",
				"next": "",
			},
			{
				"text": "没有理由",
				"response": "\"觉得不对\"不是停工的理由。没有人正式定性，这片海在明面上就还是能捕捞的。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"record_key": "ch3_dock_feeling",
				"record_value": "B",
				"next": "",
			},
		]
	},
}
