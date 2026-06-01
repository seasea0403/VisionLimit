extends "res://Script/Chapters/chapter.gd"

# ==================== 第一章特定变量 ====================
var _inference_completed: bool = false
var _email_panel: Control = null

# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(1)
	GameStateManager.reset_chapter_items(1)
	# 连接推理板信号
	if inference_panel:
		if inference_panel.has_signal("inference_success") and \
				not inference_panel.is_connected("inference_success", _on_inference_success):
			inference_panel.connect("inference_success", _on_inference_success)
		if inference_panel.has_signal("chapter_next_requested") and \
				not inference_panel.is_connected("chapter_next_requested", _on_chapter_next):
			inference_panel.connect("chapter_next_requested", _on_chapter_next)
		if inference_panel.has_signal("chapter_holdon_requested") and \
				not inference_panel.is_connected("chapter_holdon_requested", _on_chapter_holdon):
			inference_panel.connect("chapter_holdon_requested", _on_chapter_holdon)

# ==================== HUD 推理按钮（覆盖基类）====================
func _on_hud_inference_pressed() -> void:
	if _inference_completed:
		# 已完成：直接显示完成态按钮，跳过正常推理流程
		if inference_panel and inference_panel.has_method("show_completion_buttons"):
			inference_panel.call("show_completion_buttons")
			register_panel_open(inference_panel)
	else:
		super._on_hud_inference_pressed()

# ==================== 推理板完成流程 ====================
func _on_inference_success() -> void:
	_inference_completed = true
	# 关闭推理面板，移出面板栈
	if inference_panel:
		inference_panel.close_panel()
		_unregister_panel(inference_panel)
	# 显示消息 icon（位于 UILayer/HudPanel/message）
	var msg_container := get_node_or_null("UILayer/HudPanel/message") as Control
	if msg_container:
		msg_container.show()
		_play_sfx(load("res://Audio/SFX/Notification.mp3"))
		var msg_btn := msg_container.get_node_or_null("TextureButton") as BaseButton
		if msg_btn and not msg_btn.is_connected("pressed", _on_message_pressed):
			msg_btn.connect("pressed", _on_message_pressed)


func _on_message_pressed() -> void:
	# 隐藏消息按钮
	var msg_container := get_node_or_null("UILayer/HudPanel/message") as Control
	if msg_container:
		msg_container.hide()
	# 加载邮件面板（只实例化一次）
	if not is_instance_valid(_email_panel):
		var email_scene: PackedScene = load("res://Game/Scenes/Chapter1/UI/Ch1Email.tscn")
		if not email_scene:
			return
		_email_panel = email_scene.instantiate() as Control
		ui_layer.add_child(_email_panel)
		_email_panel.visibility_changed.connect(_on_email_panel_visibility_changed)
	_email_panel.show()


func _on_email_panel_visibility_changed() -> void:
	if _email_panel and not _email_panel.visible:
		# 邮件面板关闭 → 重新打开推理面板并展示完成按钮
		if inference_panel and inference_panel.has_method("show_completion_buttons"):
			inference_panel.call("show_completion_buttons")
			register_panel_open(inference_panel)


func _on_chapter_next() -> void:
	GameStateManager.complete_chapter(1)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")


func _on_chapter_holdon() -> void:
	_unregister_panel(inference_panel)


func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()

# ========================================================
# 以下为占位符，保持文件末尾干净
# ========================================================
