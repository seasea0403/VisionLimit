extends Node

# 结局三：归处
# 场景：三年后，沈意出狱，成为家乡小学的语文老师
# 人物：沈意（左）- 表情1；无右侧人物（旁白/全班）

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"

const DATA = {
	"start": {
		"text": "三年后。沈意出狱，出狱那天，她只有一个人。她回到了刚出生的地方，成为了离家里最近的一所小学里的语文老师。",
		"speaker": "",
		"portrait": "",
		"portrait_right": "",
		"active_side": "none",
		"next": "node_1"
	},
	"node_1": {
		"text": "上课！",
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "left",
		"next": "node_2"
	},
	"node_2": {
		"text": "老师好！",
		"speaker": "同学",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "none",
		"next": "node_3"
	},
	"node_3": {
		"text": "同学们好。今天，我想给大家讲一堂有关于环境的课。",
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "left",
		"next": "node_4"
	},
	"node_4": {
		"text": "在十年前，苍屿县的海还是蓝的，水还是绿的。后来，因为企业的违法行为，导致了苍屿县的环境被污染了，你们中的大多数，成为了被环境污染的苍屿症病人。",
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "left",
		"next": "node_5"
	},
	"node_5": {
		"text": "不过老师想说，你们不是病人，而是受害者。你们的世界虽然现在是黑白的，但老师相信，只要我们能坚持，一定能坚持到世界变回彩色。",
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "left",
		"next": "node_6"
	},
	"node_6": {
		"text": "老师以前做错过一些事，也因此失去了一些人。所以我不希望你们也遇到这样的事。",
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "left",
		"next": "node_7"
	},
	"node_7": {
		"text": "这个世界很美好，很广阔。老师希望你们能好好长大，好好做人，永远真诚，勇敢，善良，我们一起，一起守护苍屿，守护我们的家。",
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": "",
		"active_side": "left",
		"next": ""
	},
}
