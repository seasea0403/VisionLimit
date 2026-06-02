# ch6_final_prison.gd
# 第六章结局分支 3：入狱探视路线（结局一场景）

extends RefCounted

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"
const SY4 := "res://Art/Character/人物最终立绘/沈意-表情4.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"

const DATA: Dictionary = {
	# 入口 A：路线 A 曝光苏临后触发（且 will_regret=0）
	"a_prison": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好，我尊重你的决定。",
		"next": "a_prison_1",
	},
	"a_prison_1": {
		"speaker": "系统",
		"text": "沈意因违规操作被判处三年有期徒刑。在入狱一个月后，沈意收到了一次探视。",
		"next": "prison_common_start",
	},

	# 入口 C：路线 C 戳穿身份（且 will_regret=0）
	"c_prison": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "好，我尊重你的决定。",
		"next": "c_prison_1",
	},
	"c_prison_1": {
		"speaker": "系统",
		"text": "沈意因违规操作被判处半年有期徒刑。在入狱一个月后，沈意收到了一次探视。",
		"next": "prison_common_start",
	},

	# 共通探视对话
	"prison_common_start": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "是..你，魏江，你怎么来了。又出了什么事吗？",
		"next": "wj_1",
	},
	"wj_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "不是，什么事都没有。其实，我今天来，是想和你坦白一件事。",
		"next": "sy_1",
	},
	"sy_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "什么？",
		"next": "wj_2",
	},
	"wj_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "其实，其实我是郑和平的女儿。",
		"next": "sy_2",
	},
	"sy_2": {
		"speaker": "沈意",
		"portrait": SY4, # 路线 A 用 4，路线 C 用 3，这里兼容一下
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "什么？？",
		"next": "wj_3",
	},
	"wj_3": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我不叫魏江，我是陈星河。",
		"next": "wj_4",
	},
	"wj_4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "对。我和妈妈同年来到苍屿县，我在苍屿县环境监测局工作。工作过程中，我对某些明显被人为改动过的数据提出质疑，结果被迫离职。后来我妈妈突然晕倒，苏临突然出现，用我妈妈的生命作为威胁，让我离开苍屿县。",
		"next": "wj_5",
	},
	"wj_5": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我当然没有那么听话了。我用自己的办法骗过她，编造了魏江的假身份，继续留在苍屿县调查妈妈的事。",
		"next": "sy_3",
	},
	"sy_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "原来是这样。那你走上我，也是因为我和你妈妈接触过？",
		"next": "wj_6",
	},
	"wj_6": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "对。我黑进了苍屿县第一医院的访客记录，看到了你进入我妈妈病房的记录。又调查了你的身份，想要借你之手，扳倒苏临，再让你受到应有的惩罚。",
		"next": "sy_4",
	},
	"sy_4": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "left",
		"text": "原来是这样...那，那也对...原来是这样。",
		"next": "wj_7",
	},
	"wj_7": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "对不起，我一直在骗你。",
		"next": "sy_5",
	},
	"sy_5": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你不用感到抱歉，一切都是我应得的。",
		"next": "wj_8",
	},
	"wj_8": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你...你出来之后，我会来接你。",
		"next": "sy_6",
	},
	"sy_6": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "...",
		"next": "wj_9",
	},
	"wj_9": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你暂时不想理我也没有关系。我只想跟你说，沈意，我真的很感谢你，在你选择接入记忆的那一刻，我就相信你是个好人。案子水落石出，你的作用很大。",
		"next": "sy_7",
	},
	"sy_7": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "...这样做会让我心里好受一点，不用把我想得太高尚。",
		"next": "wj_10",
	},
	"wj_10": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "你就嘴硬吧。你，你好好的，半年后我们再见。",
		"next": "sy_final",
	},
	"sy_final": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "none",
		"text": "（沉默）",
		"next": "",
	},
}
