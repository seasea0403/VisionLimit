extends Node

# 结局一：重逢
# 人物分布：沈意(左) - portrait, 魏江(右) - portrait_right
# 沈意使用：res://Art/Character/人物最终立绘/沈意-表情1.png (2,3,4)
# 魏江使用：res://Art/Character/人物最终立绘/魏江-表情1.png (2,3)

const DATA = {
	"start": {
		"text": "沈意看向蔚蓝的天空，感到久违的舒爽。第一次，第一次这样心里没有负担地站在阳光下。她在心里对自己说。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "",
		"active_side": "left",
		"next": "node_1"
	},
	"node_1": {
		"text": "突然，她看到远处的人影。",
		"speaker": "",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "",
		"active_side": "none",
		"next": "node_2"
	},
	"node_2": {
		"text": "...？你还是来了？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "",
		"active_side": "left",
		"next": "node_3"
	},
	"node_3": {
		"text": "当然要来看看你啊。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "node_4"
	},
	"node_4": {
		"text": "看看你有没有洗心革面、重新做人？（笑）",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "node_5"
	},
	"node_5": {
		"text": "好了，开玩笑的。还好吗？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_6"
	},
	"node_6": {
		"text": "...你。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_7"
	},
	"node_7": {
		"text": "沈意闭上了眼睛，感受微风吹过脸颊。",
		"speaker": "",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "none",
		"next": "node_8"
	},
	"node_8": {
		"text": "挺好的。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_9"
	},
	"node_9": {
		"text": "什么？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_10"
	},
	"node_10": {
		"text": "我说———挺好的。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_11"
	},
	"node_11": {
		"text": "（沉默）",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_12"
	},
	"node_12": {
		"text": "你呢？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_13"
	},
	"node_13": {
		"text": "你都好，我还能不好吗。走吧。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_14"
	},
	"node_14": {
		"text": "去哪？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_15"
	},
	"node_15": {
		"text": "去医院看你妈妈啊，你不在这半年，阿姨的出院钱可都是我付的。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_16"
	},
	"node_16": {
		"text": "...哦，谢谢。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_17"
	},
	"node_17": {
		"text": "谢谢就完了，我可不是白帮你。这笔钱你得还我。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "right",
		"next": "node_18"
	},
	"node_18": {
		"text": "我会还的，不过你得给我点时间，我可能得去找一份别的工作。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "left",
		"next": "node_19"
	},
	"node_19": {
		"text": "我这有一份工作，你干不干？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_20"
	},
	"node_20": {
		"text": "干什么。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_21"
	},
	"node_21": {
		"text": "跟着我干吧。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "node_22"
	},
	"node_22": {
		"text": "？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "left",
		"next": "node_23"
	},
	"node_23": {
		"text": "我准备创业开一家神经修复机构，正好，还缺一位神经修复师，你来吧。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "right",
		"next": "node_24"
	},
	"node_24": {
		"text": "...你还相信我？",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情3.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情2.png",
		"active_side": "left",
		"next": "node_25"
	},
	"node_25": {
		"text": "干嘛那种眼神看着我？你不愿意？",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情3.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "right",
		"next": "node_26"
	},
	"node_26": {
		"text": "...愿意。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "left",
		"next": "node_27"
	},
	"node_27": {
		"text": "那快跟上啊。我跟你说啊，我刚起步，工资可给不了你太多，正好你还欠我的，你就慢慢...",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "right",
		"next": "node_28"
	},
	"node_28": {
		"text": "谢谢你，陈星河。",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情1.png",
		"active_side": "left",
		"next": "node_29"
	},
	"node_29": {
		"text": "少肉麻。",
		"speaker": "陈星河",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情1.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "right",
		"next": "node_30"
	},
	"node_30": {
		"text": "好了——走吧！",
		"speaker": "沈意",
		"portrait": "res://Art/Character/人物最终立绘/沈意-表情2.png",
		"portrait_right": "res://Art/Character/人物最终立绘/魏江-表情3.png",
		"active_side": "left",
		"next": "end"
	}
}

