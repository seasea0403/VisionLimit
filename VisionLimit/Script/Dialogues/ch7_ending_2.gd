extends Node

# 结局二：平凡生活
# 人物分布：沈意(左) - portrait, 陈星河/魏江(右) - portrait_right
# 额外素材：小孩A - res://Art/Scenes/尾声/同学.png
# 沈意使用：res://Art/Character/人物最终立绘/沈意-表情1.png (2,3)
# 陈星河(魏江素材)使用：res://Art/Character/人物最终立绘/魏江-表情1.png (2,3)

const DATA = {
	"start": {
		"text": "三年后。沈意像往常一般开启了一天的教书生活。半年前，在提交完证据之后，沈意没有告知陈星河，自己回到了她家门前的那所小学，成为了一名语文老师，每天陪伴着小孩子们。",
		"speaker": "",
		"portrait": "",
		"portrait_right": "",
		"active_side": "none",
		"next": "node_1"
	},
	"node_1": {
		"text": "上课了！大家快回到位置上坐好吧。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "",
		"active_side": "left",
		"next": "node_2"
	},
	"node_2": {
		"text": "老师！外面有个姐姐找你！",
		"speaker": "小孩A",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Scenes/尾声/同学.png",
		"active_side": "right",
		"next": "node_3"
	},
	"node_3": {
		"text": "？你们先坐好。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Scenes/尾声/同学.png",
		"active_side": "left",
		"next": "node_4"
	},
	"node_4": {
		"text": "沈意走出门外，见到了来人。",
		"speaker": "",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "",
		"active_side": "none",
		"next": "node_5"
	},
	"node_5": {
		"text": "你怎么来了？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情3.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_6"
	},
	"node_6": {
		"text": "怎么，我不能来？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情3.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_7"
	},
	"node_7": {
		"text": "不是...",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_8"
	},
	"node_8": {
		"text": "案子是两个人破的，一个人走，不够意思吧？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_9"
	},
	"node_9": {
		"text": "...",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_10"
	},
	"node_10": {
		"text": "你这人真奇怪。我都说了不怪你，到底在别扭什么？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "right",
		"next": "node_11"
	},
	"node_11": {
		"text": "我没有。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "left",
		"next": "node_12"
	},
	"node_12": {
		"text": "还骗我？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_13"
	},
	"node_13": {
		"text": "...好吧。虽然你说了原谅我，但我也不知道该怎么面对你了。对不起，是我的问题。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情3.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_14"
	},
	"node_14": {
		"text": "你怎么老在道歉啊？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情3.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_15"
	},
	"node_15": {
		"text": "啊？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_16"
	},
	"node_16": {
		"text": "以后不要再和我说对不起了。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_17"
	},
	"node_17": {
		"text": "...",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_18"
	},
	"node_18": {
		"text": "好。你来这干吗？什么时候走？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_19"
	},
	"node_19": {
		"text": "刚来就赶我走？不欢迎我？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_20"
	},
	"node_20": {
		"text": "不是..",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_21"
	},
	"node_21": {
		"text": "我可不走。听说你们这缺个英语老师？我是来面试的。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "node_22"
	},
	"node_22": {
		"text": "你来这干什么？这地方偏僻得很，你还是回去吧。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "left",
		"next": "node_23"
	},
	"node_23": {
		"text": "还说没赶我走？我可不会听你的。我知道，这地方有很多得了苍屿症的小朋友，我想进行研究，看看能不能找到修复神经的方法，这个地方正正好。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_24"
	},
	"node_24": {
		"text": "哦。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_25"
	},
	"node_25": {
		"text": "你一个人跑了，我也不跟你计较了。以后我们还得多多合作呢，沈老师。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "node_26"
	},
	"node_26": {
		"text": "走吧。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "left",
		"next": "node_27"
	},
	"node_27": {
		"text": "又赶我...?",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_28"
	},
	"node_28": {
		"text": "走吧，进去认识一下小朋友。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_29"
	},
	"node_29": {
		"text": "（笑）...好。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "end"
	}
}
