# 第五章开场对话——黑屏，在前往工作室的路上，魏江问起沈意在档案室的状态
# 双人布局：portrait（左侧沈意）+ portrait_right（右侧魏江），active_side 控制高亮

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY2 := "res://Art/Character/人物最终立绘/沈意-表情2.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"

const DATA: Dictionary = {
	# ── 线性开场 ───────────────────────────────────────────────────
	"start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "刚才你进去，到底看到什么了？",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "啊？",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "看你一出来就魂不守舍的，怎么了？",
		"choices": [
			{"text": "没什么。", "next": "a_sy1"},
			{"text": "你的真实目的到底是什么？", "next": "b_sy1"},
			{"text": "从没听你说过你的其他家人。", "next": "c_sy1"},
		],
	},

	# ══ 分支 A：没什么 ════════════════════════════════════════════
	"a_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没什么...我就是有点累了。想静一静。",
		"next": "a_wj1",
	},
	"a_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "哦...那你好好休息，等会还要修复记忆呢。",
		"next": "a_sy2",
	},
	"a_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "嗯。",
		"next": "",
	},

	# ══ 分支 B：真实目的 ══════════════════════════════════════════
	"b_sy1": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "魏江，你找我合作，真实目的到底是什么？",
		"next": "b_wj1",
	},
	"b_wj1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "（小吃惊）刚合作的时候我就跟你说过了呀，因为你工作能力强，正好能弥补我的...",
		"next": "b_sy2",
	},
	"b_sy2": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "真的吗？",
		"next": "b_wj2",
	},
	"b_wj2": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "什么真不真的？你是不是看到什...",
		"next": "b_sy3",
	},
	"b_sy3": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你就没有其他想和我说的？",
		"next": "b_wj3",
	},
	"b_wj3": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "...你是不是累了，要不要睡一会，等会还要靠你修复记忆呢。",
		"next": "b_sy4",
	},
	"b_sy4": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "...好。",
		"next": "",
	},

	# ══ 分支 C：家人 ═════════════════════════════════════════════
	"c_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "魏江。",
		"next": "c_wj1",
	},
	"c_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "嗯？",
		"next": "c_sy2",
	},
	"c_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "还从没听你说过你的其他家人，跟我说说吧？",
		"next": "c_wj2",
	},
	"c_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你不是都知道的吗，我的爸爸妈妈也因为苍屿症昏迷了...",
		"next": "c_sy3",
	},
	"c_sy3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "别的呢，你有兄弟姐妹什么的吗？",
		"next": "c_wj3",
	},
	"c_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "没有啊，怎么突然想起来问这个。",
		"next": "c_sy4",
	},
	"c_sy4": {
		"speaker": "沈意",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没事，就是好奇。（笑）",
		"next": "c_wj4",
	},
	"c_wj4": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你快休息会吧，等会还要修复记忆呢。",
		"next": "c_sy5",
	},
	"c_sy5": {
		"speaker": "沈意",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你短头发挺好看的。",
		"next": "c_wj5",
	},
	"c_wj5": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你说什么？我没听清。",
		"next": "c_sy6",
	},
	"c_sy6": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没事，睡了。",
		"next": "",
	},
}
