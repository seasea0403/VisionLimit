# 第四章开场对话——黑屏背景，沈意与魏江在前往实验室的路上的谈话
# 双人布局：portrait（左侧沈意）+ portrait_right（右侧魏江），active_side 控制高亮
# 结局走向：通过 record_key "ch4_ending" 记录
#   "good" → 沈意被谅解（结局二）：玩家选择 Aa 或 Ba
#   "bad"  → 沈意受惩罚（结局一）：玩家选择 Ab、Bb 或 C

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY2 := "res://Art/Character/人物最终立绘/沈意-表情2.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"
const SY4 := "res://Art/Character/人物最终立绘/沈意-表情4.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"

const DATA: Dictionary = {
	# ── 开场线性段落 ────────────────────────────────────────────────
	"start": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我找到的就是这些。",
		"next": "wj_1",
	},
	"wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "哇～你很厉害。",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY4,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "......有的你早都知道。",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY4,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "那也不妨碍你厉害嘛。",
		"next": "sy_3",
	},
	"sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "......",
		"next": "wj_3",
	},
	"wj_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "对了。",
		"next": "sy_4",
	},
	"sy_4": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "嗯？",
		"next": "wj_q",
	},

	# ── 关键抉择：是否如实讲述医院见到郑和平的事 ────────────────────
	"wj_q": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你在医院见到郑和平了吗？想起来什么没有？",
		"choices": [
			{"text": "实话实说。", "next": "a_sy1"},
			{"text": "反问魏江。", "next": "b_sy1"},
			{
				"text": "敷衍了事。",
				"next": "c_sy1",
				"record_key": "ch4_ending",
				"record_value": "bad",
			},
		],
	},

	# ══ 分支 A：实话实说 ═══════════════════════════════════════════
	"a_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "......没看到，不过也可以说是看到了？",
		"next": "a_wj1",
	},
	"a_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "什么意思？",
		"next": "a_sy2",
	},
	"a_sy2": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "有一个房间，我一靠近就觉得头晕，眼前一片发黑。我估计那里面应该就是郑和平吧。我虽然不记得那段记忆，但大脑应该不会骗人。我想我是真的见过她，至于做了什么，从她的记忆中看到了什么，我暂时还是想不起来。可能还需要一段时间吧，也许我会想起来。",
		"next": "a_wj2",
	},
	"a_wj2": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "哦。",
		"next": "a_sy3",
	},
	"a_sy3": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "不过，能找我过去工作的，应该也不是什么好工作吧，我可能做了一些不好的事情吧。",
		"next": "a_wj3",
	},
	"a_wj3": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "......什么意思？",
		"next": "a_sy4",
	},
	"a_sy4": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没什么意思。你不是调查过我吗，我失业之后一直接一些违规的私活，那些人不是问心有愧，就是犯了什么错，能有什么好人找我。",
		"next": "a_wj4",
	},
	"a_wj4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "那你不会良心不安吗？",
		"choices": [
			{
				"text": "也许会吧。",
				"next": "aa_sy1",
				"record_key": "ch4_ending",
				"record_value": "good",
			},
			{
				"text": "不会。",
				"next": "ab_sy1",
				"record_key": "ch4_ending",
				"record_value": "bad",
			},
		],
	},

	# ── A-a：也许会吧（→ 沈意被谅解）─────────────────────────────
	"aa_sy1": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "之前没什么感觉，现在也许...",
		"next": "aa_wj1",
	},
	"aa_wj1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "也许什么？",
		"next": "aa_sy2",
	},
	"aa_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没事，到了，我们走吧。",
		"next": "",
	},

	# ── A-b：不会（→ 沈意受惩罚）─────────────────────────────────
	"ab_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "不会啊。他们拿钱我办事，天经地义。",
		"next": "ab_wj1",
	},
	"ab_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "...哦。",
		"next": "ab_sy2",
	},
	"ab_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "到了，我们走吧。",
		"next": "",
	},

	# ══ 分支 B：反问魏江 ═══════════════════════════════════════════
	"b_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "问这个做什么？",
		"next": "b_wj1",
	},
	"b_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "好奇嘛～你见到她没有啊，那可是国家级的研究员。",
		"next": "b_sy2",
	},
	"b_sy2": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "没有...但我能感觉到她应该在那里，有一个房间，我一靠近就觉得头晕，眼前一片发黑。我估计那里面应该就是郑和平吧。我虽然不记得那段记忆，但大脑应该不会骗人。我想我是真的见过她，至于做了什么，从她的记忆中看到了什么，我暂时还是想不起来。可能还需要一段时间吧，也许我会想起来。",
		"next": "b_wj2",
	},
	"b_wj2": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "哦。",
		"next": "b_sy3",
	},
	"b_sy3": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "不过，能找我过去工作的，应该也不是什么好工作吧，我可能做了一些不好的事情吧。",
		"next": "b_wj3",
	},
	"b_wj3": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "......什么意思？",
		"next": "b_sy4",
	},
	"b_sy4": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没什么意思。你不是调查过我吗，我失业之后一直接一些违规的私活，那些人不是问心有愧，就是犯了什么错，能有什么好人找我。",
		"next": "b_wj4",
	},
	"b_wj4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "那你不会良心不安吗？",
		"choices": [
			{
				"text": "也许会吧。",
				"next": "ba_sy1",
				"record_key": "ch4_ending",
				"record_value": "good",
			},
			{
				"text": "不会。",
				"next": "bb_sy1",
				"record_key": "ch4_ending",
				"record_value": "bad",
			},
		],
	},

	# ── B-a：也许会吧（→ 沈意被谅解）─────────────────────────────
	"ba_sy1": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "之前没什么感觉，现在也许...",
		"next": "ba_wj1",
	},
	"ba_wj1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "也许什么？",
		"next": "ba_sy2",
	},
	"ba_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "没事，到了，我们走吧。",
		"next": "",
	},

	# ── B-b：不会（→ 沈意受惩罚）─────────────────────────────────
	"bb_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "不会啊。他们拿钱我办事，天经地义。",
		"next": "bb_wj1",
	},
	"bb_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "...哦。",
		"next": "bb_sy2",
	},
	"bb_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "到了，我们走吧。",
		"next": "",
	},

	# ══ 分支 C：敷衍了事（→ 沈意受惩罚）═════════════════════════
	"c_sy1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "什么？郑和平，我忘记这件事情了。",
		"next": "c_wj1",
	},
	"c_wj1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "啊？",
		"next": "c_sy2",
	},
	"c_sy2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我进去一直在抓紧时间搜证，没太注意。",
		"next": "c_wj2",
	},
	"c_wj2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好吧。但是你确定真的没看见...?",
		"next": "c_sy3",
	},
	"c_sy3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "（打断）到了，我们走吧。",
		"next": "",
	},
}
