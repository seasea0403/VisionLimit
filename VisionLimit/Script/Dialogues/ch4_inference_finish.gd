extends RefCounted

# 第四章 推理完成后的真相揭露对话
# 使用 人物最终立绘 系列表情

const DATA: Dictionary = {
	"start": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "你现在还要骗我吗？",
		"next": "node2"
	},
	"node2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"text": "我真没骗你，这就是公司正常的环境监测。",
		"next": "node3"
	},
	"node3": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "right",
		"text": "你应该知道环境监测的数据对一个企业来说也是商业机密。",
		"next": "node4"
	},
	"node4": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "left",
		"text": "商业机密？我看你是在掩盖污染事实！那份数据报告根本就是伪造的！",
		"next": "node5"
	},
	"node5": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "你...你怎么发现的？",
		"next": "node6"
	},
	"node6": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "我在档案室里看到了，临深集团成立了一家独立的环境监测公司，所有的监测报告都是那家公司出的，完全就是为了掩人耳目。",
		"next": "node7"
	},
	"node7": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "原来是这样...看来我们之前的调查方向是对的。",
		"next": "node8"
	},
	"node8": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "但是这些证据还不够，我们需要更直接的证据。如果有人还存有一手的检测数据的话...",
		"next": "node9"
	},
	"node9": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "我知道了，是......",
		"choices": [
			{"text": "A. 我", "next": "choiceA_1"},
			{"text": "B. 郑和平", "next": "choiceB_1"}
		]
	},
	"choiceA_1": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "是我！",
		"next": "choiceA_2"
	},
	"choiceA_2": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "别开玩笑了，你怎么会有...你是说？",
		"next": "choiceA_3"
	},
	"choiceA_3": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "对，虽然我被删除了接入郑和平记忆海的那段经历，但我相信，她记忆力量的强大性，足以将证据完整地传入到我的记忆中。不然也不会一靠近她，我的神经就出现波动。",
		"next": "choiceA_4"
	},
	"choiceA_4": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "虽然我没有百分之百的把握...不过总要试一试！去我的工作室吧，我可以试着进入我的记忆海，试着唤醒那段记忆。",
		"next": "choiceA_5"
	},
	"choiceB_1": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "我和你想的一样！不过，像你之前说的，你被派去接触郑和平，肯定已经将她的记忆都删除了。",
		"next": "choiceB_2"
	},
	"choiceB_2": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "对，但是我觉得，我应该会保有她这部分的记忆。",
		"next": "choiceB_3"
	},
	"choiceB_3": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "为什么？你怎么知道？",
		"next": "choiceB_4"
	},
	"choiceB_4": {
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"text": "是一种感觉。我相信郑和平的精神力量足够强大，不然我也不会一靠近她，神经就出现波动。虽然我没有百分之百的把握...不过总要试一试！去我的工作室吧，我可以试着进入我的记忆海，试着唤醒那段记忆。",
		"next": "choiceB_5"
	},
	"choiceA_5": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "好，那我们走吧。",
		"next": "end"
	},
	"choiceB_5": {
		"speaker": "魏江",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"text": "好，我们也只能试这一把了。",
		"next": "end"
	}
}
