# 第四章档案室入场对话——进入场景后的对话，魏江与沈意商量分工
# 双人布局：portrait（左侧沈意）+ portrait_right（右侧魏江），active_side 控制高亮

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY2 := "res://Art/Character/人物最终立绘/沈意-表情2.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你带我来环境保护局的档案室干什么？",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你有没有想过，为什么苍屿症出现了这么多年，苍屿县一直没被曝出有任何环境问题。",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "现在缺少的一环，应该都在这里了。这是最好的选择。",
		"next": "sy_3",
	},
	"sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "不过，你来过这里？",
		"next": "wj_1",
	},
	"wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我怎么可能来过。不过外面这么多保安，我们怎么进去？",
		"next": "sy_4",
	},
	"sy_4": {
		"speaker": "沈意",
		"portrait": SY2,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "不是有你吗。",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "？",
		"next": "sy_5",
	},
	"sy_5": {
		"speaker": "沈意",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你去引开保安，我进去找线索。要不你以为我为什么带你一起来。",
		"next": "wj_3",
	},
	"wj_3": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "凭什么不是你去？",
		"next": "sy_6",
	},
	"sy_6": {
		"speaker": "沈意",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "凭我有接入记忆的能力。不是你说的吗。（笑）",
		"next": "wj_4",
	},
	"wj_4": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好吧...那你千万要快，我们随时耳机沟通！",
		"next": "wj_5",
	},
	"wj_5": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（跑向保安）喂，我在这！",
		"next": "",
	},
}
