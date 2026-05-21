# 第三章-医院对话数据
# 使用方式：
#   const CH3Hospital = preload("res://Script/Dialogues/ch3_hospital.gd")
#   DialogueManager.start_dialogue(CH3Hospital.DATA, "start")
#
# 线索条件说明：
#   clue_brochure    → 搜集到苍屿症宣传册后解锁"缺位"选项
#   clue_appointment → 点击预约区便签和台账后解锁"有明显异常"选项

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "这家医院比我想的更安静。安静得不正常。\n我们对一遍信息？",
		"choices": [
			{"text": "我再走一圈。", "next": "q1"},
			{"text": "好，对一下。", "next": "q1"},
		]
	},
	"q1": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "你怎么看这里对苍屿症的官方态度？",
		"choices": [
			{
				"text": "缺位",
				"response": "缺位：找不到任何官方渠道的资料，家属在自己印册子——官方没有缺席，是主动让位。",
				"next": "q2",
				"condition": "clue_brochure",
			},
			{
				"text": "含糊",
				"response": "含糊：没有明确表态，也没有明确否认——一切都悬在中间。",
				"next": "q2",
			},
		]
	},
	"q2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "神经护理区的预约有没有问题？",
		"choices": [
			{
				"text": "有明显异常",
				"response": "有明显异常：预约人数与到场人数对不上，部分患者被反复改期，便签上写着\"已满\"。表格干净，背后是把人推出去的动作。",
				"next": "q3",
				"condition": "clue_appointment",
			},
			{
				"text": "没看到异常",
				"response": "没看到异常：流程规范，记录完整。",
				"next": "q3",
			},
		]
	},
	"q3": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江张手.png",
		"text": "好，我大致清楚了。接下来去旧码头。\n（他犹豫了一下。）\n说说你的感受——那幅画，白色的鱼，灰色的海。家属们自己组互助小组，自己印册子，自己在告示栏底层留感谢信。没有人替他们说话，他们就替彼此说。\n你怎么看？",
		"choices": [
			{
				"text": "沉默也是一种态度。",
				"response": "「沉默也是一种态度。官方不开口，家属就只剩下彼此。」",
				"next": "",
				"record_key": "ch3_hospital_sentiment",
				"record_value": "A",
			},
			{
				"text": "他们还在来。",
				"response": "「他们还在来。被改期，被绕开，他们还在来。我说不清这种坚持是什么。」",
				"next": "",
				"record_key": "ch3_hospital_sentiment",
				"record_value": "B",
			},
			{
				"text": "我想到了郑和平。",
				"response": "「我想到了郑和平。她停不下来——不是有人在等她，是数据不允许她停下来。」",
				"next": "",
				"record_key": "ch3_hospital_sentiment",
				"record_value": "C",
			},
		]
	},
}
