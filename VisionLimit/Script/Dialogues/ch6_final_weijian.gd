# ch6_final_weijian.gd
# 第六章结局分支 1：证据板整理后，与魏江的最后谈话

extends RefCounted

const SY1 := "res://Art/Character/人物最终立绘/沈意-表情1.png"
const SY2 := "res://Art/Character/人物最终立绘/沈意-表情2.png"
const SY3 := "res://Art/Character/人物最终立绘/沈意-表情3.png"
const WJ1 := "res://Art/Character/人物最终立绘/魏江-表情1.png"
const WJ2 := "res://Art/Character/人物最终立绘/魏江-表情2.png"
const WJ3 := "res://Art/Character/人物最终立绘/魏江-表情3.png"

const DATA: Dictionary = {
	"start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "我已经拿到线索了。我们一起去揭发苏临吧。",
		"choices": [
			{"text": "揭发苏临", "response": "好。我的证据也已经整理好了。", "record_key": "ch7_final_choice", "record_value": "expose", "next": "expose_start"},
			{"text": "扣下证据", "response": "对不起。", "record_key": "ch7_final_choice", "record_value": "hide", "next": "hide_start"},
			{"text": "你骗了我", "condition": "ch3_found_archive", "response": "先等等。魏江，你骗了我。", "record_key": "ch7_final_choice", "record_value": "c_reveal", "next": "c_reveal_start"},
		],
	},

	# ===== 路线 A：揭发苏临 =====
	"expose_start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ2,
		"active_side": "right",
		"text": "这么爽快？",
		"next": "expose_1",
	},
	"expose_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你真的想好了？证据链提交上去，你的操作也会被公之于众，惩罚是免不了的。",
		"choices": [
			{"text": "你在犹豫什么", "response": "（笑）事是我做的，你这么犹犹豫豫做什么？", "next": "a_sy_1"},
			{"text": "我已经决定了", "response": "我已经决定了。在记忆海中，我才意识到自己做错的后果有多严重。我对不起郑和平，惩罚是我应得的。", "next": "b_sy_1"},
		],
	},
	"a_sy_1": {
		"speaker": "魏江",
		"portrait": SY2,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你...",
		"next": "a_sy_2",
	},
	"a_sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "在记忆海中，我才意识到自己做错的后果有多严重。我对不起郑和平，如果会受到惩罚是我应得的。",
		"next": "",
	},
	"b_sy_1": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "不会后悔吗？",
		"next": "b_sy_2",
	},
	"b_sy_2": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "不后悔。虽然可能日子会难了点，不过再难的日子我也挺过去了。",
		"next": "",
	},

	# ===== 路线 B：扣下证据 =====
	"hide_start": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "......你什么意思？",
		"next": "hide_1",
	},
	"hide_1": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "我不打算检举了。",
		"next": "hide_2",
	},
	"hide_2": {
		"speaker": "魏江",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "为什么？！",
		"next": "hide_3",
	},
	"hide_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "苏临说得对。精炼厂确实给苍屿县的人们提供了很多岗位，精炼厂关了，他们怎么活？苍屿症，苍屿症也并没有致命。",
		"next": "hide_4",
	},
	"hide_4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "他们就不无辜吗？沈意，你怎么会说出这样的话？",
		"next": "hide_5",
	},
	"hide_5": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "none",
		"text": "（沉默）",
		"next": "hide_6",
	},
	"hide_6": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我知道你在想什么，不举报苏临，你的违规操作就不会被发现。",
		"next": "hide_7",
	},
	"hide_7": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "你说的对，你没必要为了和你无关的人，舍弃自己的利益。",
		"next": "hide_8",
	},
	"hide_8": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "但是沈意，证据我是一定要提交的，其实，在你工作室的时候，我偷偷备份了所有的证据，不需要你，我也可以检举苏临。",
		"next": "hide_sy",
	},
	"hide_sy": {
		"speaker": "沈意",
		"portrait": SY3,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "对不起。",
		"next": "hide_wj",
	},
	"hide_wj": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我不接受。",
		"next": "",
	},

	# ===== 路线 C：你骗了我 =====
	"c_reveal_start": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "什么？你在说什么？",
		"next": "c_reveal_1",
	},
	"c_reveal_1": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你真的想说吗，陈星河？",
		"next": "c_reveal_2",
	},
	"c_reveal_2": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "...你都知道了？在环保局的时候。",
		"next": "c_reveal_3",
	},
	"c_reveal_3": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "对。我看到了你和郑和平的照片。",
		"next": "c_reveal_4",
	},
	"c_reveal_4": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ3,
		"active_side": "right",
		"text": "我是骗你了。当年我和妈妈同年来到苍屿县，我在苍屿县环境监测局工作。工作过程中，我对某些明显被人为改动过的数据提出质疑，结果被迫离职。后来我妈妈突然晕倒，苏临突然出现，用我妈妈的生命作为威胁，让我离开苍屿县。",
		"next": "c_reveal_5",
	},
	"c_reveal_5": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我当然没有那么听话了。我用自己的办法骗过她，编造了魏江的假身份，继续留在苍屿县调查妈妈的事。",
		"next": "c_reveal_6",
	},
	"c_reveal_6": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "我找你，也不是因为你的资质。我黑进了苍屿县第一医院的访客记录，看到了你进入我妈妈病房的记录。又调查了你的身份，想要借你之手，扳倒苏临，再让你受到应有的惩罚。",
		"next": "c_reveal_7",
	},
	"c_reveal_7": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "原来是这样。",
		"next": "c_reveal_8",
	},
	"c_reveal_8": {
		"speaker": "魏江",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "right",
		"text": "对不起，我骗了你。",
		"next": "c_reveal_9",
	},
	"c_reveal_9": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你为什么要和我说对不起？是我做错了。在记忆海中，我才意识到自己做错的后果有多严重。我对不起郑和平，如果会受到惩罚是我应得的。",
		"next": "c_reveal_10",
	},
	"c_reveal_10": {
		"speaker": "沈意",
		"portrait": SY1,
		"portrait_right": WJ1,
		"active_side": "left",
		"text": "你别忘了，我妈妈也在医院里。",
		"next": "",
	},
}
