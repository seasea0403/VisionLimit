# 第三章-母亲病房入室对话数据
# door_confirm  → 进入病房前确认选项（A: 退出；B: 继续）
# wj_radio_*    → 进入病房后魏江与沈意的无线电简报

const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"

const DATA: Dictionary = {
	# ── 入室确认选项 ─────────────────────────────────────────────────────
	"door_confirm": {
		"speaker": "",
		"text": "提示：这是母亲的病房。\n你确定要进入此病房了吗？",
		"choices": [
			{"text": "不确定，再看一会吧。", "record_key": "ch3_door_choice", "record_value": "a", "next": ""},
			{"text": "确定", "record_key": "ch3_door_choice", "record_value": "b", "next": "wj_radio"},
		],
	},
	# ── 无线电简报 ────────────────────────────────────────────────────────
	"wj_radio": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "沈意，你那边怎么样？",
		"next": "sy_radio",
	},
	"sy_radio": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我进入我妈妈的病房了。她之前是码头的工人，我想接入她的记忆，看看能不能找到什么有用的线索。",
		"next": "wj_radio_2",
	},
	"wj_radio_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好。",
		"next": "sy_monologue",
	},
	# ── 沈意入室前独白 ───────────────────────────────────────────────────
	"sy_monologue": {
		"speaker": "沈意",
		"portrait": SY1,
		"text": "这是我妈妈的病房。她出事前，我很少回来，也从来没发觉过她生病了。也许这次我能找到她生病前的一些事。",
		"next": "",
	},
}
