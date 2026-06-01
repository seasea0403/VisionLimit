# 第三章进入医院后——魏江通过耳机联系沈意（消息icon触发）
# 双人布局：portrait（左/沈意）+ portrait_right（右/魏江），active_side 控制高亮
# 对话结束后玩家自由搜证

const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"
const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "沈意，你进去了吗？",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我刚进来，病房里人很少。",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "你听好了，刚才媒体突然报道了一例苍屿症患者突发精神狂暴，医院通知，近期要对苍屿症病房进行封锁，不准任何人进入。",
		"next": "wj_3",
	},
	"wj_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "今天是我们唯一的机会了。",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "好，我知道了。",
		"next": "",
	},
}
