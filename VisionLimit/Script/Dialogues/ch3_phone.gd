# 第三章·黄色牌子电话交互对话
# item_id=8 点击继续后触发；A=拨打，B=不打

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY4 := "res://Art/Character/人物最终立绘/沈意-表情4.png"

const DATA: Dictionary = {
	# 问题节点：只显示选项，无说话人文字
	"start": {
		"speaker": "",
		"portrait": SY1,
		"active_side": "none",
		"text": "是否要拨打电话？",
		"choices": [
			{
				"text": "打",
				"next": "a_result",
			},
			{
				"text": "不打",
				"next": "b_result",
			},
		],
	},

	# ══ A：打 ══
	"a_result": {
		"speaker": "",
		"portrait": SY4,
		"active_side": "none",
		"text": "对不起，您所拨打的已占线，请稍后再拨。",
		"next": "a_sy",
	},
	"a_sy": {
		"speaker": "沈意",
		"portrait": SY4,
		"active_side": "left",
		"text": "到底在搞什么名堂。",
		"next": "",
	},

	# ══ B：不打 ══
	"b_result": {
		"speaker": "沈意",
		"portrait": SY1,
		"active_side": "left",
		"text": "算了，先去别的地方看看。",
		"next": "",
	},
}
