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
				"response": "他在钓我。他知道一些我不知道的事，想看我的反应。",
				"next": "",
			},
			{
				"text": "巧合",
				"response": "他大概只是顺着病历名单找过来。我只是名单上一个名字。",
				"next": "",
			},
			{
				"text": "困惑",
				"response": "我说不上来。但他特地写了那个名字，就是想让我有反应——而我确实有了。",
				"next": "",
			},
		],
	},
}
