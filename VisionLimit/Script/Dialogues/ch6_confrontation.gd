# ch6_confrontation.gd
# Stage 6：郑和平与苏临的争执对话

const _ZHP := "res://Art/Character/人物最终立绘/郑和平.png"
const _SL  := "res://Art/Character/人物最终立绘/苏临.png"

const DATA: Dictionary = {
	"0": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "你怎么会变成现在这个样子！",
		"next": "1"
	},
	"1": {
		"speaker": "苏临",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "right",
		"text": "变？郑和平，我从来都没变过。",
		"next": "2"
	},
	"2": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "这就是你口中的理想？你眼里除了钱还有什么？",
		"next": "3"
	},
	"3": {
		"speaker": "苏临",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "right",
		"text": "学姐。这么多年，你还是这么天真。你就永远高高在上地活在你的象牙塔里吧。你知道精炼厂给苍屿县提供了多少工作岗位吗？你去问问路上的人，谁能不感谢我苏临？没有我，苍屿早就完了。",
		"next": "4"
	},
	"4": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "那那些得病的人呢？",
		"next": "5"
	},
	"5": {
		"speaker": "苏临",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "right",
		"text": "（冷笑）成功是需要代价的，学姐。苍屿县会记住他们的付出的。",
		"next": "6"
	},
	"6": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "你真是疯了。",
		"next": "7"
	},
	"7": {
		"speaker": "苏临",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "right",
		"text": "当作什么事情都没发生，好好回你的研究所去，我们都万事大吉。学姐，以后我们还是可以像这样叙叙旧的。",
		"next": "8"
	},
	"8": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "我们没得聊了。",
		"next": "9"
	},
	"9": {
		"speaker": "苏临",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "right",
		"text": "你一直在质问我，学姐，我很伤心，好歹我们也做过几年同窗。",
		"next": "10"
	},
	"10": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "不要再叫我学姐了。苏临，我给你三天时间，三天之内你不去自首，我会将所有证据提交给警方。",
		"next": "11"
	},
	"11": {
		"speaker": "苏临",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "right",
		"text": "你在威胁我？你以为我会怕吗。",
		"next": "12"
	},
	"12": {
		"speaker": "郑和平",
		"portrait": _ZHP,
		"portrait_right": _SL,
		"active_side": "left",
		"text": "我真希望当初从来没有认识过你。",
		"next": ""
	},
}
