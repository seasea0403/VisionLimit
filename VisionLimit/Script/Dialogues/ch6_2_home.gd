# ch6_2_home.gd
# 第六章——沈意回家后的内心独白与选择

extends RefCounted

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "沈意",
		"portrait": SY1,
		"active_side": "left",
		"text": "这一天过得好快...苍屿县和苍屿症背后的问题都浮出水面了。没想到会这么顺利，不过...",
		"choices": [
			{
				"text": "苏临怎么没有出现",
				"response": "在记忆海中，我看到了苏临让我删除郑和平记忆的场景。按她的性格，怎么会现在都没有动静？",
				"next": "",
			},
			{
				"text": "我和郑和平的事",
				"response": "如果临深集团和苏临被揭发，我违规接入郑和平记忆的事应该也瞒不住了。后果会怎么样呢？",
				"next": "",
			},
		],
	},
}
