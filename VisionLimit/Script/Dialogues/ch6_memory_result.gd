# ch6_memory_result.gd
# 从记忆海返回后——魏江与沈意的对话

extends RefCounted

const SY := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const WJ := "res://Art/Character/人物最终立绘/魏江-表情1.png"

const DATA: Dictionary = {
	"0": {
		"speaker": "魏江",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "right",
		"text": "你醒了，感觉怎么样？",
		"next": "1"
	},
	"1": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "left",
		"text": "...",
		"next": "2"
	},
	"2": {
		"speaker": "魏江",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "right",
		"text": "你不会失忆了吧？",
		"next": "3"
	},
	"3": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "left",
		"text": "你小点声好不好，我头好痛。",
		"next": "4"
	},
	"4": {
		"speaker": "魏江",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "right",
		"text": "啊，不好意思，你现在感觉怎么样？",
		"next": "5"
	},
	"5": {
		"speaker": "沈意",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "left",
		"text": "和我想的一样，郑和平的记忆反向储存在了我的记忆里，我看到了她找到的关键证据。",
		"next": "6"
	},
	"6": {
		"speaker": "魏江",
		"portrait": SY,
		"portrait_right": WJ,
		"active_side": "right",
		"text": "太好了，这就是我们要找的最后一环。",
		"next": ""
	},
}
