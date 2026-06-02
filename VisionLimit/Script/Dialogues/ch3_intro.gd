# 第三章开场对话——草丛场景，魏江与沈意合作前谈话
# 双人布局：portrait（左侧沈意）+ portrait_right（右侧魏江），active_side 控制高亮
# 流程：线性五句 → wj_3 分支选择（A/B）→ 各自收尾 → dialogue_finished

const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"
const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"

const DATA: Dictionary = {
	# ── 开场线性段落 ──────────────────────────────────────────────────────
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我们合作了。",
		"next": "wj_1",
	},
	"wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "嗯？对啊。",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "那你可以告诉我，你和郑和平是什么关系？",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "这很重要吗？",
		"next": "sy_3",
	},
	"sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我只是想知道，你为什么要调查她，为什么你的办公室里会有那么多与她有关的东西？",
		"next": "wj_3",
	},
	# ── 分支点：魏江讲述郑和平 ────────────────────────────────────────────
	"wj_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "（沉默片刻）郑和平是一名水文地质研究员。8年前，苍屿症在苍屿县突然爆发式出现，郑和平恰好收到委托来到苍屿进行环境调查，结果来了四年，她突然就被宣告昏迷了，也住在这间医院。这太蹊跷了。",
		"choices": [
			{
				"text": "郑和平查到关键信息了？",
				"response": "你是说，郑和平查到了苍屿症背后的关键信息，导致受到了某种迫害？",
				"response_portrait": SY1,
				"record_key": "ch3_will_regret",
				"record_value": "1",
				"next": "a_wj1",
			},
			{
				"text": "郑和平也患上苍屿症了？",
				"response": "你是说，郑和平在调查的过程中，也患上了苍屿症，苍屿症不是独属于苍屿县的基因疾病？",
				"response_portrait": SY1,
				"record_key": "ch3_will_regret",
				"record_value": "0",
				"next": "b_wj1",
			},
		],
	},

	# ══ 分支 A：郑和平查到关键信息 ═══════════════════════════════════════
	"a_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我认为是这样的。外界都说，苍屿症是苍屿县人们独有的疾病，是由于基因导致的，但背后的原因一定没有这么草率。",
		"next": "a_sy1",
	},
	"a_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "（思考）",
		"next": "a_wj2",
	},
	"a_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "医院里神经管控病房对外人进入的控制很严，我进不去。",
		"next": "a_wj3",
	},
	"a_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（笑）但是我知道你妈妈住在里面，里面的情况就靠你了。",
		"next": "a_sy2",
	},
	"a_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "...好。",
		"next": "a_wj4",
	},
	"a_wj4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "小心行事。（掏出一只耳机，自己带上另一只）这个耳机给你，我们随时联系。",
		"next": "a_sy3",
	},
	"a_sy3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "嗯。",
		"next": "a_wj5",
	},
	"a_wj5": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "我在外面等你。",
		"next": "",
	},

	# ══ 分支 B：郑和平也患上苍屿症 ══════════════════════════════════════
	"b_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我不能百分百确定。但确定的是，苍屿症背后的原因绝没有外界说的基因病这么简单。",
		"next": "b_sy1",
	},
	"b_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "（思考）",
		"next": "b_wj2",
	},
	"b_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "医院里神经管控病房对外人进入的控制很严，我进不去。",
		"next": "b_wj3",
	},
	"b_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（笑）但是我知道你妈妈住在里面，里面的情况就靠你了。",
		"next": "b_sy2",
	},
	"b_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "...好。",
		"next": "b_wj4",
	},
	"b_wj4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "小心行事。（掏出一只耳机，自己带上另一只）这个耳机给你，我们随时联系。你看到新消息就点开，我们语音沟通。",
		"next": "b_sy3",
	},
	"b_sy3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "嗯。",
		"next": "b_wj5",
	},
	"b_wj5": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "我在外面等你。",
		"next": "",
	},
}
