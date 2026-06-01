extends "res://Script/Chapters/chapter.gd"

const Ch6_2Home = preload("res://Script/Dialogues/ch6_2_home.gd")
const Ch6_2SulinCall = preload("res://Script/Dialogues/ch6_2_sulin_call.gd")


func _ready() -> void:
	is_chapter_continuation = true
	super._ready()
	GameStateManager.set_current_chapter(7)

	zoom_views_root.hide()
	ui_layer.hide()

	if not DialogueManager.dialogue_finished.is_connected(_on_home_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_home_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6_2Home.DATA, "start")


# ==================== 独白结束，进入房间 ====================
func _on_home_dialogue_finished() -> void:
	zoom_views_root.show()
	ui_layer.show()
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

	# 显示苏临电话图片
	var message_image := get_node_or_null("messageimage") as TextureRect
	if message_image:
		message_image.show()

	if not DialogueManager.dialogue_finished.is_connected(_on_call_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_call_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6_2SulinCall.DATA, "start")


# ==================== 通话结束 ====================
func _on_call_dialogue_finished() -> void:
	var message_image := get_node_or_null("messageimage") as TextureRect
	if message_image:
		message_image.hide()
