# 第三章推理板完成后的出口对话——草丛场景重聚
# 流程：开场三句 → wj_2 三路选择（A:病房 / B:码头 / C:苏临）
#        路线 A → 二级选择（a.照片 / b.鱼）→ 各自收尾
#        路线 B → 二级选择（a.录音笔 / b.日记）→ 各自收尾
#        路线 C → 线性收尾

const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"
const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"

const DATA: Dictionary = {
	# ── 开场三句 ──────────────────────────────────────────────────────────
	"wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "（招手）这边。",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "left",
		"text": "嗯。",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "怎么样？有没有找到什么有用的线索？",
		"choices": [
			{
				"text": "病房",
				"response": "病房给我的感觉不太对劲...我不知道怎么形容，也许是...一种很冰冷的感觉？尤其是对待苍屿症患者的冷漠。我怀疑苍屿症的症状也有夸大的成分。医院说晚期的症状还有精神错乱，但我觉得应该不是这样。",
				"response_portrait": SY3,
				"next": "wj_a1",
			},
			{
				"text": "码头",
				"response": "我在妈妈的记忆里看到了她工作的码头...码头很不对劲，船的到港情况、鱼的数量波动，这些数据都是有问题的，是被人改过的。",
				"response_portrait": SY3,
				"next": "wj_b1",
			},
			{
				"text": "苏临",
				"response": "苏临...苏临，我在两个地方都看到了苏临的名字，一次在医院，一次在码头。",
				"response_portrait": SY3,
				"next": "wj_c1",
			},
		],
	},

	# ══ 路线 A：病房 ══════════════════════════════════════════════════════
	"wj_a1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "（愤愤）苍屿症根本没有他们说的那么严重！我走访的时候，大量的患者都只是轻微的症状。之前医院出过一桩新闻，几个患者和医生吵起来了，之后那几个患者就以精神错乱的理由被关起来了。",
		"next": "sy_a2",
	},
	"sy_a2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "原来是这样。看来医院也脱不了干系。我还记得...",
		"choices": [
			{"text": "照片", "next": "sy_aa1"},
			{"text": "鱼", "next": "sy_ab1"},
		],
	},

	# A-a：照片 ───────────────────────────────────────────────────────────
	"sy_aa1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "我记得护士台摆着一张照片...苏临，是苏临，这家医院的出资方是临深集团。",
		"next": "wj_aa1",
	},
	"wj_aa1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "哦...",
		"next": "sy_aa2",
	},
	"sy_aa2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我在妈妈的记忆里也看到了类似的信息...我们先去下一个地方吧，剩下的我慢慢路上和你讲。",
		"next": "wj_aa2",
	},
	"wj_aa2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "好，咱们去哪？",
		"next": "sy_aa3",
	},
	"sy_aa3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "（思考）你地图上标的最后一个地方——精炼厂。",
		"next": "",
	},

	# A-b：鱼 ─────────────────────────────────────────────────────────────
	"sy_ab1": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "我在妈妈的记忆看到了码头里的鱼，明明个头那么大，还卖的那么便宜...",
		"next": "wj_ab1",
	},
	"wj_ab1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你是说，苍屿的水出了问题，导致鱼有了异常？",
		"next": "sy_ab2",
	},
	"sy_ab2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "走，我们先去下一个地方，剩下的我慢慢路上和你讲。",
		"next": "wj_ab2",
	},
	"wj_ab2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好，咱们去哪？",
		"next": "sy_ab3",
	},
	"sy_ab3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "（思考）与苍屿县的环境最密切的——环境保护局",
		"next": "",
	},

	# ══ 路线 B：码头 ══════════════════════════════════════════════════════
	"wj_b1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "码头也是被控制的？他们为什么写假数据，难道因为鱼有问题吗？",
		"next": "sy_b2",
	},
	"sy_b2": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "我觉得就是这样。我还记得...",
		"choices": [
			{"text": "录音笔", "next": "sy_ba1"},
			{"text": "日记", "next": "sy_bb1"},
		],
	},

	# B-a：录音笔 ─────────────────────────────────────────────────────────
	"sy_ba1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "还记得你桌子上那支录音笔吗？我记得郑和平说，某片水域的检测...汞含量超标了，苍屿县的鱼，大概率是被污染了。",
		"next": "wj_ba1",
	},
	"wj_ba1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "那么人们只要吃了鱼，喝了水，都会间接导致中毒的概率上升，才会导致苍屿症的出现。",
		"next": "sy_ba2",
	},
	"sy_ba2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "对，我们先去下一个地方，剩下的我慢慢路上和你讲。",
		"next": "wj_ba2",
	},
	"wj_ba2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好，咱们去哪？",
		"next": "sy_ba3",
	},
	"sy_ba3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "（思考）与苍屿县的环境最密切的——环境保护局",
		"next": "",
	},

	# B-b：日记 ───────────────────────────────────────────────────────────
	"sy_bb1": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "我妈妈41年3月的日记里写，食堂里的鱼变多了，之前码头根本舍不得给工人们吃鱼...鱼肯定携带某种病毒，或者是...水！",
		"next": "wj_bb1",
	},
	"wj_bb1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "这样，人们只要吃了鱼，喝了水，都会间接导致中毒的概率上升，就会导致苍屿症的出现。",
		"next": "sy_bb2",
	},
	"sy_bb2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "对，我们先去下一个地方，剩下的我慢慢路上和你讲。",
		"next": "wj_bb2",
	},
	"wj_bb2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好，咱们去哪？",
		"next": "sy_bb3",
	},
	"sy_bb3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "（思考）与苍屿县的环境最密切的——环境保护局",
		"next": "",
	},

	# ══ 路线 C：苏临 ══════════════════════════════════════════════════════
	"wj_c1": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "（不自然）你是说，医院和码头里的怪异之处，都是苏临在背后控制？",
		"next": "sy_c2",
	},
	"sy_c2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "不能排除这种可能，医院和码头都有临深集团的出资，这两个地方的实际话事人大概率就是苏临了。但现在还不能百分百确定，我们需要更多线索。",
		"next": "wj_c2",
	},
	"wj_c2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好，听你的，我们现在去哪里？",
		"next": "sy_c3",
	},
	"sy_c3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "（思考）与苍屿县的环境最密切的——环境保护局。剩下的，我路上慢慢和你说。",
		"next": "",
	},
}
