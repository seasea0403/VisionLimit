# ch6_final_good.gd
# 第六章结局分支 2：陈星河（魏江）的坦白与谅解（结局二路线）

extends RefCounted

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"
const SY4 := "res://Art/Character/人物最终立绘/沈意-表情4.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"

const DATA: Dictionary = {
	# 入口 A：路线 A 曝光苏临后触发（且 will_regret=1）
	"a_good": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我听说，如果得到记忆被接入者家属的谅解，是可以免去惩罚的。",
		"next": "a_sy1",
	},
	"a_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "...嗯？",
		"next": "a_wj1",
	},
	"a_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "这时候了，我也不想瞒你了。其实...",
		"next": "a_wj2",
	},
	"a_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "其实我是郑和平的女儿。",
		"next": "a_sy2",
	},
	"a_sy2": {
		"speaker": "沈意",
		"portrait": SY4,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "什么？？",
		"next": "a_wj3",
	},
	"a_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我不叫魏江，我是陈星河。",
		"next": "common_reveal",
	},

	# 入口 C：路线 C 戳穿身份后触发（且 will_regret=1）
	"c_good": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "其实，我听说，如果得到记忆被接入者家属的谅解，是可以免去惩罚的。",
		"next": "c_sy1",
	},
	"c_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "？",
		"next": "common_reveal",
	},

	# 共通对话
	"common_reveal": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "这两天相处下来，我感觉你并不是一个坏人向。我相信你是真心觉得自己错了，当初的委托，你也不是故意的。",
		"next": "common_1",
	},
	"common_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "你是个好人，沈意，谢谢你，我们完成了这次调查。",
		"next": "common_2",
	},
	"common_2": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "对不起...",
		"next": "common_3",
	},
	"common_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "没事。苍屿县，会变得越来越好的。",
		"next": "final_choice",
	},
	"final_choice": {
		"speaker": "系统",
		"text": "所有证据已备齐，确定要向警方提交检举材料吗？",
		"choices": [
			{"text": "提交检举", "response": "提交所有证据。", "next": ""},
		],
	},
}
