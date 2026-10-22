# 第一章-邮件后沈意自白对话数据
# 使用方式：
#   const Ch1Email = preload("res://Script/Dialogues/ch1_email.gd")
#   DialogueManager.start_dialogue(Ch1Email.DATA, "start")

const DATA: Dictionary = {
	"start": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/沈意常规.png",
		"text": "这个魏江，到底想从我这里拿到什么？",
		"choices": [
			{
				"text": "试探",
				"response": "他在试探我。他真的知道一些关于苍屿症的内幕，想看看我的反应？",
				"next": "",
			},
			{
				"text": "巧合",
				"response": "他可能只是顺着苍屿症的病历名单挨个找过来，我不过是被选中了。或许我该去看看这个有缘人。",
				"next": "",
			},
			{
				"text": "困惑",
				"response": "为什么是我？他又知道些什么？但他特地提到了苍屿症，就是想引起我的兴趣吧。我得去见见他。",
				"next": "",
			},
		],
	},
}
