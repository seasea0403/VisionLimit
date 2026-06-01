# ch6_2_sulin_call.gd
# 第六章——苏临来电，沈意接听后的完整对话

extends RefCounted

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SL1 := "res://Art/Character/人物最终立绘/苏临.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "是你。",
		"next": "sl_1",
	},
	"sl_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "你们动作很快。",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "你打来做什么？",
		"next": "sl_2",
	},
	"sl_2": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "你和那个记者的行动，我一早就知道了，一个被开除的记者，和一个违规操作的人，能搞出什么动静？我一点也不担心。",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "那你还打来电话做什么？",
		"next": "sl_3",
	},
	"sl_3": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "（笑）四年前我说过，你拿完钱，洗了记忆，我们就再也不要见面，你也不要再参与这件事。没想到你啊，失去了记忆，还能卷入这件事。沈意啊沈意，你为什么总是这么不听话。",
		"next": "sy_3",
	},
	"sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "你以为，删掉郑和平脑子里的东西，苍屿症的秘密就能被永远掩盖了吗？",
		"next": "sl_4",
	},
	"sl_4": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "记忆并不是证据。没有法庭认可的格式，没有来源认证，没有完整的检测链。从一个昏迷病人神经残留里拿出来的东西不会有任何价值。",
		"choices": [
			{"text": "你在害怕", "response": "你在害怕。你亲自出面，已经意识到了事情的严重性。", "next": "a_sl_1"},
			{"text": "我后悔了", "response": "我后悔了。", "next": "b_sl_1"},
		],
	},

	# ===== 选项 A：你在害怕 =====
	"a_sl_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "我亲自来，是因为我希望我想要的一切都能在我的控制中。我今天就要你永远把嘴闭上。",
		"next": "a_sy_1",
	},
	"a_sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "我知道你在说谎。",
		"next": "merge_1",
	},

	# ===== 选项 B：我后悔了 =====
	"b_sl_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "我早就说过了，你不应该再调查这件事，拿了钱...",
		"next": "b_sy_1",
	},
	"b_sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "我后悔四年前答应了你的委托。我现在才明白，四年前我以为我只是完成了一单工作，但是我毁了一个科学家四年的心血，也让苍屿县无辜多受了四年迫害。",
		"next": "merge_1",
	},

	# ===== 汇合 =====
	"merge_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "你太天真了！你现在还能站在这里跟我好好讲话，是因为我还愿意给你一个机会。",
		"next": "merge_2",
	},
	"merge_2": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "沈意，你别忘了，你的执照是二级。而你对郑和平操作的，是三级共生和四级干预，越级操作，没有任何授权。你比我更清楚这意味着什么。",
		"next": "sy_4",
	},
	"sy_4": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "left",
		"text": "你在威胁我。",
		"next": "sl_5",
	},
	"sl_5": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "我只是在陈述事实。",
		"choices": [
			{"text": "你要我放弃郑和平的记忆。", "response": "你要我放弃郑和平的记忆，你会帮我掩盖违规操作的事实？", "next": "c_sl_1"},
			{"text": "你的话我都录下来了。", "response": "你的话我都录下了，这也能成为证据的一部分。", "next": "d_sl_1"},
		],
	},

	# ===== 选项 C：放弃郑和平的记忆 =====
	"c_sl_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "你是个聪明人，有些路走下去，代价只会很大。",
		"next": "final_1",
	},

	# ===== 选项 D：我都录下来了 =====
	"d_sl_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "一个录音而已。这么多年，总有不长眼力的记者乱写些报道，你有看到过一篇吗。我说得很明白了。",
		"next": "final_1",
	},

	# ===== 苏临最后的话 =====
	"final_1": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "我最后再说一次。\n你们手上的东西，我可以让它什么都不是。那些证据，证据的来源......每一条可以攻击的薄弱节点，我都有足够的资源和足够的时间来解决。",
		"next": "final_2",
	},
	"final_2": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "但我也可以让这件事就此结束。\n你把证据都交出来，你的法律风险一笔勾销，郑和平那边的医疗条件，我会继续保障。\n这是一个公平的安排。",
		"next": "final_3",
	},
	"final_3": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "苍屿需要那座精炼厂。你们把这件事掀出去，工厂停产，八百多人即将失业。事情没你们想的那么简单。",
		"next": "final_4",
	},
	"final_4": {
		"speaker": "苏临",
		"portrait": SY1,
		"portrait_right": SL1,
		"active_side": "right",
		"text": "你们有二十四小时做决定。你和你的记者，要想清楚。",
		"next": "",
	},
}
