extends "res://Script/Chapters/chapter.gd"

const Ch6_2Home = preload("res://Script/Dialogues/ch6_2_home.gd")
const Ch6_2SulinCall = preload("res://Script/Dialogues/ch6_2_sulin_call.gd")
const Ch6FinalWeijian = preload("res://Script/Dialogues/ch6_final_weijian.gd")
const Ch6FinalGood = preload("res://Script/Dialogues/ch6_final_good.gd")
const Ch6FinalPrison = preload("res://Script/Dialogues/ch6_final_prison.gd")
const Ch6FinalHide = preload("res://Script/Dialogues/ch6_final_hide.gd")

var _proof_scene = preload("res://Game/Scenes/Chapter7/UI/proofpanel.tscn")

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
		if msg_btn:
			if msg_btn.is_connected("pressed", _on_message_pressed):
				msg_btn.disconnect("pressed", _on_message_pressed)
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


# ==================== 通话结束，弹出证据板 ====================
func _on_call_dialogue_finished() -> void:
	var message_image := get_node_or_null("messageimage") as TextureRect
	if message_image:
		message_image.hide()
	
	_show_proof_panel()

func _show_proof_panel() -> void:
	var proof_layer = CanvasLayer.new()
	proof_layer.layer = 5
	add_child(proof_layer)

	var proof: Node = _proof_scene.instantiate()
	proof_layer.add_child(proof)
	
	if proof.has_signal("panel_completed"):
		proof.connect("panel_completed", _on_proof_completed)

# ==================== 证据板整理结束，魏江发来消息 ====================
func _on_proof_completed() -> void:
	_show_weijian_message_icon()

func _show_weijian_message_icon() -> void:
	var msg_container := get_node_or_null("UILayer/HudPanel/message") as Control
	if msg_container:
		msg_container.show()
		_play_sfx(load("res://Audio/SFX/Notification.mp3"))
		var msg_btn := msg_container.get_node_or_null("TextureButton") as BaseButton
		if msg_btn:
			if msg_btn.is_connected("pressed", _on_message_pressed):
				msg_btn.disconnect("pressed", _on_message_pressed)
			msg_btn.connect("pressed", _on_weijian_message_pressed)

func _on_weijian_message_pressed() -> void:
	var msg_container := get_node_or_null("UILayer/HudPanel/message") as Control
	if msg_container:
		msg_container.hide()
	
	if not DialogueManager.dialogue_finished.is_connected(_on_weijian_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_weijian_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6FinalWeijian.DATA, "start")

# ==================== 魏江第一阶段对话结束，根据选择路由 ====================
func _on_weijian_dialogue_finished() -> void:
	var choice = GameStateManager.get_record("ch7_final_choice")
	var will_regret = GameStateManager.get_record("ch3_will_regret") == "1"
	
	match choice:
		"hide":
			_play_hide_ending()
		"expose":
			if will_regret:
				_play_good_ending("a_good")
			else:
				_play_prison_ending("a_prison")
		"c_reveal":
			if will_regret:
				_play_good_ending("c_good")
			else:
				_play_prison_ending("c_prison")

# ==================== 结局分支播放逻辑 ====================
func _play_good_ending(start_id: String) -> void:
	DialogueManager.dialogue_finished.connect(func():
		SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter7/3/结局二.tscn")
	, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6FinalGood.DATA, start_id)

func _play_prison_ending(start_id: String) -> void:
	DialogueManager.dialogue_finished.connect(func():
		SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter7/3/结局一.tscn")
	, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6FinalPrison.DATA, start_id)

func _play_hide_ending() -> void:
	DialogueManager.dialogue_finished.connect(func():
		SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter7/3/结局三.tscn")
	, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6FinalHide.DATA, "start")
