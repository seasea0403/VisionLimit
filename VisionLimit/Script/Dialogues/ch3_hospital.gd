# 第三章-医院对话数据
# clue_brochure    → 查看苍屿症宣传册（便签纸 item_id="5"）后解锁"缺位"选项
# clue_appointment → 查看粉色便签(item_id="2")和预约记录(item_id="4")后解锁"有明显异常"选项

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江.png",
		"text": "这家医院比我想的更安静，安静得不正常。我们对一遍信息？",
		"choices": [
			{"text": "我再走一圈。", "next": "__exit__"},
			{"text": "好，对一下。", "next": "q1"},
		],
	},
	"q1": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "你怎么看这里对苍屿症的官方态度？",
		"choices": [
			{
				"text": "缺位",
				"response": "找不到任何官方渠道的资料，家属在自己印册子。官方对苍屿症的定义仍是\"地方性疑难杂症\"，缺乏明确的治疗和预防手段。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q2",
				"condition": "clue_brochure",
			},
			{
				"text": "含糊",
				"response": "没有获得相关的信息，官方对苍屿症缺乏明确的界定。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q2",
			},
		],
	},
	"q2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江抱胸思考.png",
		"text": "神经护理区的预约有没有问题？",
		"choices": [
			{
				"text": "有明显异常",
				"response": "预约人数与到场人数对不上，部分患者被反复改期，医院似乎在逃避接收苍屿症患者。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q3",
				"condition": "clue_appointment",
			},
			{
				"text": "没看到异常",
				"response": "没发现有异常的地方，预约流程规范，记录完整。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"next": "q3",
			},
		],
	},
	"q3": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/魏江张手.png",
		"text": "好，我大致清楚了。接下来去旧码头。\n（他犹豫了一下。）\n待了这一圈，你对这家医院有什么感觉？",
		"choices": [
			{
				"text": "压抑",
				"response": "比我预想的压抑。医院的神经护理区规矩很多，但又没给人带来多少希望。",
				"response_portrait": "res://Art/Character/沈意叹气.png",
				"record_key": "ch3_hospital_feeling",
				"record_value": "A",
				"next": "",
			},
			{
				"text": "无感",
				"response": "没什么特别的，我在类似的地方待过，习惯了。",
				"response_portrait": "res://Art/Character/沈意常规.png",
				"record_key": "ch3_hospital_feeling",
				"record_value": "B",
				"next": "",
			},
			{
				"text": "好奇",
				"response": "我一直在想郑和平住在这里是什么感受，她究竟有没有知觉。",
				"response_portrait": "res://Art/Character/沈意叹气.png",
				"record_key": "ch3_hospital_feeling",
				"record_value": "C",
				"next": "",
			},
		],
	},
}
