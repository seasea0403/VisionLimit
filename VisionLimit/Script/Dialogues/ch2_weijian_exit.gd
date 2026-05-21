# 第二章-魏江关卡出口对话
# 录音听完后，魏江询问是否准备开始推理阶段
# 使用方式：
#   const Ch2WeijianExit = preload("res://Script/Dialogues/ch2_weijian_exit.gd")
#   DialogueManager.start_dialogue(Ch2WeijianExit.DATA, "start")

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "你还有想再翻看的东西吗？还是我们可以开始把它们摆一起了。",
		"choices": [
			{
				"text": "我再看看。",
				"record_key": "ch2_exit_choice",
				"record_value": "look",
				"next": "",
			},
			{
				"text": "可以了，开始吧。",
				"record_key": "ch2_exit_choice",
				"record_value": "start",
				"next": "",
			},
		],
	},
}
