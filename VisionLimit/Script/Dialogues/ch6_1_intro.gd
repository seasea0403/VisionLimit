# ch6_1_intro.gd
# 第六章开场——沈意工作室，找到全部证据后与魏江的对话及选择

extends RefCounted

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我们找到全部的证据了。现在你想怎么做？",
		"next": "wj_1",
	},
	"wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "既然证据齐全，我们现在就去检举苏临和临深集团吧！",
		"choices": [
			{"text": "好的", "response": "好，我们现在就去。", "next": "a_wj_1"},
			{"text": "等等", "response": "等等！要不我们还是...再等等吧。", "next": "b_wj_1"},
		],
	},

	# ===== 选项 A：好的 =====
	"a_wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "不过，有些证据还在我办公室里，我需要先回去拿一趟。",
		"next": "a_wj_2",
	},
	"a_wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你先回家吧，到时候我会联系你！我们随时保持联络。",
		"next": "a_sy_1",
	},
	"a_sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "好。",
		"next": "",
	},

	# ===== 选项 B：等等 =====
	"b_wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（笑）为什么？",
		"next": "b_sy_1",
	},
	"b_sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "虽然关键证据有了，但其他证据还在你办公室里，你先回去拿一趟吧。",
		"next": "b_wj_2",
	},
	"b_wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "这样啊。我还以为是你不想去呢。",
		"next": "b_sy_2",
	},
	"b_sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "none",
		"text": "（沉默）",
		"next": "b_wj_3",
	},
	"b_wj_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你先回家吧，到时候我会联系你。",
		"next": "b_sy_3",
	},
	"b_sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "好。",
		"next": "",
	},
}
