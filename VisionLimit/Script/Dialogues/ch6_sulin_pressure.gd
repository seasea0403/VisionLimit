# ch6_sulin_pressure.gd
# 记忆接入完成后——苏临逼迫沈意的对话

extends RefCounted

const SY := "res://Art/Character/人物最终立绘/沈意-表情3.png"
const SL := "res://Art/Character/人物最终立绘/苏临.png"

const DATA: Dictionary = {
	"0": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "left",
		"text": "...不行....你们刚开始说的只是...",
		"next": "1"
	},
	"1": {
		"speaker": "苏临",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "right",
		"text": "年轻人，事你已经做了，还差再往下一步吗。",
		"next": "2"
	},
	"2": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "left",
		"text": "你们这是不合规的，她是...",
		"next": "3"
	},
	"3": {
		"speaker": "苏临",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "right",
		"text": "（笑）你现在是和我讨论是否合规吗？你忘了你自己是做什么的了吗沈意，你没有和我商量的余地。",
		"next": "4"
	},
	"4": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "left",
		"text": "（沉默）",
		"next": "5"
	},
	"5": {
		"speaker": "苏临",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "right",
		"text": "想想你妈妈，她还在医院里躺着吧。",
		"next": "6"
	},
	"6": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "left",
		"text": "（沉默）",
		"next": "7"
	},
	"7": {
		"speaker": "苏临",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "right",
		"text": "不用担心，事成以后，你什么都不会记得，到时候拿着钱，我们也不会再见面。",
		"next": "8"
	},
	"8": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "left",
		"text": "好。",
		"next": "9"
	},
	"9": {
		"speaker": "苏临",
		"portrait": SY,
		"portrait_right": SL,
		"active_side": "right",
		"text": "做你该做的。",
		"next": ""
	},
}
