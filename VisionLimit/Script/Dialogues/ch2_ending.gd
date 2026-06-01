# 第二章-最终对话序列（InferencePanel 完成后）
# 流程：魏江大头出现 → 双人布局三选一（A/B/C）→ 汇合对话 → 触发 UI/1 推理板
#       → 推理板完成后继续后半段 → 第二次三选一（A/B/C）→ 各路收尾
# 特殊 next 值：
#   "__puzzle__" → chapter2.gd 拦截，打开 UI/1 推理板，完成后跳 "post_puzzle"
# 双人布局字段：
#   portrait       = 左侧沈意立绘路径
#   portrait_right = 右侧魏江立绘路径
#   active_side    = "left"/"right"/"none"/"" (""=旧行为，不暗化)
# 使用方式：
#   const Ch2Ending = preload("res://Script/Dialogues/ch2_ending.gd")
#   DialogueManager.start_dialogue(Ch2Ending.DATA, "start")

const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"
const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY2 := "res://Art/Character/人物最终立绘/沈意-表情2.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"

const DATA: Dictionary = {
	# ── 大头登场（大头节点单独展示，对话框仅显文字）──────────────────────
	"start": {
		"speaker": "魏江",
		"portrait_head": "res://Art/Character/人物大头/魏江大头.png",
		"text": "你来了？我果然没有看错人。",
		"next": "choice1",
	},

	# ── 第一次三选一 ──────────────────────────────────────────────────────
	"choice1": {
		"speaker": "",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "none",
		"text": "",
		"choices": [
			{
				"text": "你是故意让我看到这些线索的？",
				"response": "你故意不出现，就是为了让我自己进来，然后看到你调查的这些线索？为什么找我来帮你。",
				"response_portrait": SY2,
				"record_key": "ch2_first_choice",
				"record_value": "A",
				"next": "a_wj1",
			},
			{
				"text": "你很没有时间观念。",
				"response": "你在邮件里约我四点见面，却现在才出现，你们记者不是最追求时效性吗？",
				"response_portrait": SY2,
				"record_key": "ch2_first_choice",
				"record_value": "B",
				"next": "b_wj1",
			},
			{
				"text": "我收费很高，没有钱就别找我。",
				"response": "你们做记者的工资很高吗？我收费很贵，钱不到位的话我是不会同意帮你的。",
				"response_portrait": SY2,
				"record_key": "ch2_first_choice",
				"record_value": "C",
				"next": "c_wj1",
			},
		],
	},

	# ── 选A分支 ──────────────────────────────────────────────────────────
	"a_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "就像我跟你说过的一样，我们的父母都出现了同样的症状，我不相信这是巧合。",
		"next": "a_wj2",
	},
	"a_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你也看到了，我之前写过的稿子一发出去就被撤掉了，我现在一个人能做的很有限，我需要你的职业资质，我需要你和我一起查清楚这件事。",
		"next": "a_silence",
	},
	"a_silence": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "none",
		"text": "……",
		"next": "a_wj3",
	},
	"a_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "如果出了什么事，我都担着，答应你的钱也不会少。",
		"next": "merge_1",
	},

	# ── 选B分支 ──────────────────────────────────────────────────────────
	"b_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（笑）我要试试你的诚意嘛。不过看你待了这么久也没走，看来这案子你也很感兴趣吧。",
		"next": "b_sy1",
	},
	"b_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "……说说吧，到底要我做什么。",
		"next": "b_wj2",
	},
	"b_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我们的父母都出现了同样的症状，我不相信这是巧合。",
		"next": "b_wj3",
	},
	"b_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "你也看到了，我之前写过的稿子一发出去就被撤掉了，我现在一个人能做的很有限，我需要你的职业资质，我需要你和我一起查清楚这件事。",
		"next": "merge_1",
	},

	# ── 选C分支 ──────────────────────────────────────────────────────────
	"c_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（笑）这个你放心吧，没有钱我是不会找你的，不会让你白帮忙的。不过你很缺钱吗？",
		"next": "c_sy1",
	},
	"c_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "要我做些什么。",
		"next": "c_wj2",
	},
	"c_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "好吧。我们的父母都出现了同样的症状，我不相信这是巧合。",
		"next": "c_wj3",
	},
	"c_wj3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你也看到了，我之前写过的稿子一发出去就被撤掉了，我现在一个人能做的很有限，我需要你的职业资质，我需要你和我一起查清楚这件事。",
		"next": "merge_1",
	},

	# ── ABC汇合：共同对话段 ──────────────────────────────────────────────
	"merge_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "……你调查我。",
		"next": "merge_2",
	},
	"merge_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（笑）好吧，既然要合作，我就不会隐瞒你。",
		"next": "merge_3",
	},
	"merge_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我确实调查过你，因为你是唯一接触过昏迷的郑和平的人。郑和平研究员6年前来到苍屿县调研环境，但却在46年8月突然陷入昏迷，你不觉得这很蹊跷吗？",
		"next": "merge_4",
	},
	"merge_4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我写的稿子也被人撤掉了，苍屿症，和苍屿县的环境到底出了什么问题，背后一定有更大的势力。",
		"next": "merge_5",
	},
	"merge_5": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "none",
		"text": "……",
		"next": "merge_6",
	},
	"merge_6": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我说完了，该看的你也都看到了，到你了吧。说说吧，你和郑和平见面的时候，都做什么了，你看到她记忆里的什么了？",
		"next": "merge_7",
	},
	"merge_7": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "我不记得了。",
		"next": "merge_8",
	},
	"merge_8": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "？",
		"next": "merge_9",
	},
	"merge_9": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "（摇头）我不记得了。我不记得郑和平，也不记得自己见过她。",
		"next": "merge_10",
	},
	"merge_10": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "如果像你说的一样，那我应该是接到了某份委托，又在对方的要求下删除了这段工作记忆。",
		"next": "merge_11",
	},
	"merge_11": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "……",
		"next": "merge_12",
	},
	"merge_12": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "我答应和你的合作。但我现在知道的也不多，我们先梳理一下你房间中的线索。",
		"next": "merge_13",
	},
	"merge_13": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好。",
		"next": "__puzzle__",
	},

	# ── 推理板（UI/1）完成后继续 ─────────────────────────────────────────
	"post_puzzle": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "这就是现在摆在我们面前的谜团，接下来就要去一一弄清它们。（笑）那我们就明天见吧，先去苍屿第一神经医院。",
		"next": "choice2",
	},

	# ── 第二次三选一 ─────────────────────────────────────────────────────
	"choice2": {
		"speaker": "",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "none",
		"text": "",
		"choices": [
			{
				"text": "你怎么老是笑",
				"response": "有没有人说过你……没事，我走了。",
				"response_portrait": SY1,
				"record_key": "ch2_second_choice",
				"record_value": "A",
				"next": "end_a_wj",
			},
			{
				"text": "去那里做什么？",
				"response": "医院会有什么重要线索吗？我们去那里有用吗？",
				"response_portrait": SY1,
				"record_key": "ch2_second_choice",
				"record_value": "B",
				"next": "end_b_wj1",
			},
			{
				"text": "你早就想好要去那了？",
				"response": "你早就想好要去医院了？",
				"response_portrait": SY1,
				"record_key": "ch2_second_choice",
				"record_value": "C",
				"next": "end_c_wj1",
			},
		],
	},

	# ── 结尾A ─────────────────────────────────────────────────────────────
	"end_a_wj": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "（笑）行，再见啊。",
		"next": "end_a_sy",
	},
	"end_a_sy": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "……记得把定金打给我。",
		"next": "",
	},

	# ── 结尾B ─────────────────────────────────────────────────────────────
	"end_b_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "这么说吧，那是离苍屿症患者最近的地方了。",
		"next": "end_b_sy1",
	},
	"end_b_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "好。",
		"next": "end_b_wj2",
	},
	"end_b_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "你还真是惜字如金啊。明天九点见了，别迟到。",
		"next": "end_b_sy2",
	},
	"end_b_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "管好你自己就可以。",
		"next": "",
	},

	# ── 结尾C ─────────────────────────────────────────────────────────────
	"end_c_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "对。那里面的患者对我们的调查很有意义。但是医院管制得很严，除了病患和家属，没有人能轻易进入到苍屿症症状病房里。而且……",
		"next": "end_c_sy1",
	},
	"end_c_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "而且什么？",
		"next": "end_c_wj2",
	},
	"end_c_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我听说，郑和平也在那里。",
		"next": "end_c_sy2",
	},
	"end_c_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "什么？好，我妈妈也在那里住院，我想我应该有办法进去。",
		"next": "",
	},
}
