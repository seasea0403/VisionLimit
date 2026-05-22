extends RefCounted

const DATA: Dictionary = {
"start": {
"speaker": "沈意",
"portrait": "res://Art/Character/人物立绘/沈意.png",
"text": "（这是？苏临的视频通话？她怎么找过来的？）",
"next": "start_sulin"
},
"start_sulin": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "沈意。我知道你在那里，也知道你身边那位记者朋友在。\n四年前，你拿了钱，洗了记忆，转身离开。我们之间的事，那时候就应该结束了。你不应该再回头。",
"choices": [
{
"text": "直截了当", 
"response": "你以为删掉郑和平脑子里的东西，证据就不存在了，你想让苍屿症的秘密永远被掩盖。", 
"next": "r1_1"
},
{
"text": "后知后觉", 
"response": "我现在才明白，四年前我做的是什么，我销毁了一个科学家四年的心血。", 
"next": "r1_2"
},
{
"text": "主动出击", 
"response": "临深集团的掌权人，晴野基金会的掌舵者，你愿意亲自出面解决，是不是说明这件事对你的意义非同凡响？", 
"next": "r1_3"
}
]
},
"r1_1": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "记忆并不是证据。没有法庭认可的格式，没有来源认证，没有完整的检测链。从一个昏迷病人神经残留里拿出来的东西，是幻觉。你拿出的证据不会有任何价值。",
"next": "r2_intro"
},
"r1_2": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "你当时明白。你拿了接近十倍市价的委托费，亲手操作删除了郑和平的记忆。你选择了不明白，因为不明白对你而言更划算。现在你想反悔，这笔账，由谁来付？",
"next": "r2_intro"
},
"r1_3": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "我亲自来，是因为我不想走到需要别人替我处理这件事的那一步。我喜欢直接把所有事情把我在自己手中。",
"next": "r2_intro"
},
"r2_intro": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "我来，是给你们一个机会，在这件事变得复杂之前结束它。\n沈意，你的执照是二级。你在2046年那场委托里执行的，按对方留存的操作日志，是三级共生，甚至是四级干预，越级操作，没有任何授权。你比我更清楚这意味什么。",
"next": "r2_weijiang"
},
"r2_weijiang": {
"speaker": "魏江",
"portrait": "res://Art/Character/魏江.png",
"text": "你在威胁她。",
"next": "r2_sulin"
},
"r2_sulin": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "我在陈述事实。这不是我的事实，是她的事实。任何证据进入司法程序之前，都会先经历一轮来源审查，她手上的每一份东西，都会先被这一轮审查照过一遍。",
"choices": [
{
"text": "交换", 
"response": "所以你要我放弃郑和平脑子里的东西，以此来交换你对我的赦免？", 
"next": "r2_1"
},
{
"text": "记录", 
"response": "你现在说的所有话，魏江都在录。这也将成为我们证据的一部分。", 
"next": "r2_2"
}
]
},
"r2_1": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "我不需要交换。我只是在告诉你，有些路走下去，代价很高，而且未必能走到你以为的那个地方。",
"next": "r3_intro"
},
"r2_2": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "魏江先生。你上一次成功发出去的稿子，是2046年7月。之后四年，你一篇也没出去。不是因为你没有线索，更不是因为证据不充分。\n我想我说得很明白了。",
"next": "r3_intro"
},
"r3_intro": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "我最后再说一次。\n你们手上的东西，我可以让它什么都不是。沈意的接入记录、证据的来源......对于每一条可以攻击的薄弱节点，我有足够的资源和足够的时间。",
"next": "r3_intro2"
},
"r3_intro2": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "但我也可以让这件事就此结束。\n你们把数据包交出来，沈意的法律风险一笔勾销，郑和平那边的医疗条件，我会继续保障。\n这是一个公平的安排。",
"next": "r3_intro3"
},
"r3_intro3": {
"speaker": "苏临",
"portrait": "res://Art/Character/人物立绘/苏临.png",
"text": "苍屿需要那座精炼厂。渔业撑不住的这些年里，是它给这里的人发的工资。\n你们把这件事掀出去，工厂停产，八百多人即将失业。事情没你们想的那么简单。\n你们有二十四小时做决定。",
"next": ""
}
}