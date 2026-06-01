extends "res://Script/Chapters/chapter.gd"

# ==================== 对话数据 ====================
const Ch3Hospital = preload("res://Script/Dialogues/ch3_hospital.gd")
const Ch3Intro = preload("res://Script/Dialogues/ch3_intro.gd")
const Ch3Message = preload("res://Script/Dialogues/ch3_message.gd")
const Ch3Phone = preload("res://Script/Dialogues/ch3_phone.gd")

# ==================== 状态 ====================
## 魏江是否已被点击过一次（第一次=开场白，第二次=触发对话）
var _weijian_clicked: bool = false
## 是否已查看苍屿症宣传册（便签纸 item_id="5"）
var _saw_brochure: bool = false
## 是否已查看粉色便签（item_id="2"）
var _saw_pinknote: bool = false
## 是否已查看预约记录/台账（item_id="4"）
var _saw_record: bool = false

## 草丛开场覆盖层
var _opening_overlay: CanvasLayer = null
## 专属于本章 ItemDetail 的「继续」按钮（仅 item_id=8 时显示）
var _continue_button: Button = null


func _ready() -> void:
	chapter_number = 3
	super._ready()
	item_detail.detail_opened.connect(_on_detail_opened)
	_continue_button = item_detail.get_node_or_null("Control/ContinueButton") as Button
	if _continue_button:
		_continue_button.pressed.connect(_on_continue_button_pressed)
		item_detail.panel_closed.connect(func(): _continue_button.visible = false)

	# 获取开场背景覆盖层
	_opening_overlay = get_node_or_null("OpeningOverlay") as CanvasLayer

	# 隐藏医院场景和 HUD，等待开场对话结束后再显示
	zoom_views_root.hide()
	ui_layer.hide()

	# 启动草丛开场对话
	if not DialogueManager.dialogue_finished.is_connected(_on_intro_finished):
		DialogueManager.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch3Intro.DATA, "sy_1")


# ==================== 开场对话完成 ====================
func _on_intro_finished() -> void:
	# 隐藏草丛背景覆盖层
	if is_instance_valid(_opening_overlay):
		_opening_overlay.hide()
	# 正式进入医院场景
	zoom_views_root.show()
	ui_layer.show()
	# 立即显示消息 icon
	_show_message_icon()


# ==================== 消息 icon ====================
func _show_message_icon() -> void:
	var msg_container := get_node_or_null("UILayer/HudPanel/message") as Control
	if msg_container:
		msg_container.show()
		_play_sfx(load("res://Audio/SFX/Notification.mp3"))
		var msg_btn := msg_container.get_node_or_null("TextureButton") as BaseButton
		if msg_btn and not msg_btn.is_connected("pressed", _on_message_pressed):
			msg_btn.connect("pressed", _on_message_pressed)


func _on_message_pressed() -> void:
	var msg_container := get_node_or_null("UILayer/HudPanel/message") as Control
	if msg_container:
		msg_container.hide()
	if not DialogueManager.dialogue_finished.is_connected(_on_message_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_message_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch3Message.DATA, "start")


func _on_message_dialogue_finished() -> void:
	pass  # 对话结束，玩家自由搜证


# ==================== 物品查看追踪 ====================
func _on_detail_opened(item_id: String) -> void:
	match item_id:
		"1":  # 魏江 — 第一次显示开场白，第二次开始对话
			if not _weijian_clicked:
				_weijian_clicked = true
			else:
				item_detail.close_detail()
				_start_hospital_dialogue()
		"5":  # 苍屿症宣传册（便签纸）
			if not _saw_brochure:
				_saw_brochure = true
				GameStateManager.set_clue("clue_brochure")
		"2":  # 粉色便签（查看即解锁预约异常线索）
			if not _saw_pinknote:
				_saw_pinknote = true
				GameStateManager.set_clue("clue_appointment")
		"4":  # 预约记录（台账）— 同样单独查看即解锁
			if not _saw_record:
				_saw_record = true
				GameStateManager.set_clue("clue_appointment")
		"8":  # 黄色牌子——显示专属「继续」按钮，点击后触发电话交互
			if _continue_button:
				_continue_button.visible = true


# ==================== 「继续」按钮（仅 item_id=8 专用）====================
func _on_continue_button_pressed() -> void:
	_continue_button.visible = false
	item_detail.close_detail()
	if not DialogueManager.dialogue_finished.is_connected(_on_phone_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_phone_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch3Phone.DATA, "start")



func _on_phone_dialogue_finished() -> void:
	pass  # 电话对话结束，回到自由搜证


# ==================== 医院对话 ====================
func _start_hospital_dialogue() -> void:
	# 防止玩家选「我再走一圈」退出后再次触发时重复连接
	if not DialogueManager.dialogue_finished.is_connected(_on_hospital_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_hospital_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch3Hospital.DATA, "start")


func _on_hospital_dialogue_finished() -> void:
	GameStateManager.complete_chapter(3)
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter3/2/chapter_3_2.tscn")
