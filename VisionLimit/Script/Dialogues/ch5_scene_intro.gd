# 第五章入场对话——到达沈意工作室后，魏江第一次来到沈意的地盘

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "哇，我还是第一次到你的地盘来。",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "none",
		"text": "（沉默）",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "不过你一个无业游民，干嘛还需要一个房间当工作室啊？",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "...找我的人很多，干活的话，有个地方会比较方便。",
		"next": "wj_3",
	},
	"wj_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "哦。那我们现在开始吗？我需要做什么。",
		"next": "sy_3",
	},
	"sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你安静一点就可以了。",
		"next": "",
	},
}
