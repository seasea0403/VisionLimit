# 第二章-最终对话序列（拼图完成后）
# 沈意自白 → 魏江请求帮助 → 魏江三选一提问（记录入 ch2_shenyi_choice，影响第七章）
# 使用方式：
#   const Ch2Ending = preload("res://Script/Dialogues/ch2_ending.gd")
#   DialogueManager.start_dialogue(Ch2Ending.DATA, "start")

const DATA: Dictionary = {
	"start": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/沈意叹气.png",
		"text": "我能告诉你的是，四年前我接过一笔记忆紊乱的治疗委托，种种迹象都指向那个患者是郑和平。但委托结束后，我经历了一次严格的记忆清洗，那段经历我几乎什么都留不住了。",
		"next": "w1",
	},
	"w1": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "谢谢你说这些。我现在手里缺一块关键的东西——我高度怀疑郑和平的昏迷，和她把大量苍屿症数据写入记忆海有关，记忆超载最终引发了紊乱。你是跟她密切接触过的人，我需要你的帮助。",
		"next": "w2",
	},
	"w2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江张手.png",
		"text": "我们要去苍屿实地看一趟。出发之前，我想先问你一件事。\n\n如果有一天郑和平醒过来，发现是你删掉了她攒了四年的那些东西，你觉得她会怎么看你？",
		"choices": [
			{
				"text": "矛盾：她会理解，但她不会原谅我。这两件事可以同时成立。",
				"record_key": "ch2_shenyi_choice",
				"record_value": "A",
				"next": "",
			},
			{
				"text": "回避：我没办法替她回答这个问题。",
				"record_key": "ch2_shenyi_choice",
				"record_value": "B",
				"next": "",
			},
			{
				"text": "重点：这不重要了。重要的是我们现在还能做什么。",
				"record_key": "ch2_shenyi_choice",
				"record_value": "C",
				"next": "",
			},
		],
	},
}
