extends "res://Script/Chapters/chapter.gd"

# 结局音乐资源路径 —— 将此路径替换为你希望播放的音乐文件
const ENDING_MUSIC_PATH := "res://Audio/BGM/NewBGM.mp3"

# ItemDetail 本地「播放」按钮（仅限本场景）
@onready var _play_btn: Node = $"UILayer/ItemDetail/Control/PlayRecordButton"


# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()
	# 第7章的续集场景，不重置物品（第7章第一场已重置）
	GameStateManager.set_current_chapter(7)

	# 连接 ItemDetail 信号
	item_detail.detail_opened.connect(_on_detail_opened)
	item_detail.panel_closed.connect(_on_item_detail_closed)

	# 连接本地播放按钮
	_play_btn.get_node("TextureButton").pressed.connect(_on_play_pressed)


# ==================== ItemDetail 拦截 ====================
func _on_detail_opened(item_id: String) -> void:
	# 仅在查看播放器（item_id == "2"）时显示播放按钮
	_play_btn.visible = (item_id == "2")


func _on_item_detail_closed() -> void:
	_play_btn.visible = false


# ==================== 播放按钮逻辑 ====================
func _on_play_pressed() -> void:
	# 1. 立刻停止本场景所有 BGM（chapter_7_2_* 的 SceneBgm 均继承自 Chapter.tscn）
	var bgm: AudioStreamPlayer2D = get_node_or_null("SceneBgm")
	if bgm:
		bgm.stop()

	# 2. 通过 GameStateManager 跨场景持续播放结局音乐，并标记结局音乐激活
	var new_stream: AudioStream = load(ENDING_MUSIC_PATH)
	GameStateManager.play_global_music(new_stream, 0.0)

	# 3. 关闭 ItemDetail
	item_detail.close_detail()

	# 4. 开始结局淡出序列
	_start_ending_fade()


func _start_ending_fade() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	# ── 全屏黑色遮罩（从透明缓缓变黑）──
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay.position = Vector2.ZERO
	overlay.size = viewport_size
	overlay.z_index = 200
	ui_layer.add_child(overlay)

	# ── 「感谢游玩」文字（初始透明，随后淡入）──
	var label := Label.new()
	label.text = "感谢游玩"
	label.position = Vector2.ZERO
	label.size = viewport_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 72)
	label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	label.z_index = 201
	ui_layer.add_child(label)

	# ── Tween 序列 ──
	var tween := create_tween()
	# ① 缓缓变暗，约 6 秒（EASE_IN + TRANS_CUBIC 让开头极慢、结尾加速）
	tween.tween_property(overlay, "color",
			Color(0.0, 0.0, 0.0, 1.0), 6.0
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	# ② 文字淡入，2 秒
	tween.tween_property(label, "modulate",
			Color(1.0, 1.0, 1.0, 1.0), 2.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	# ③ 停留 3 秒
	tween.tween_interval(3.0)
	# ④ 切回主界面（音乐由 GameStateManager 维持，不会随场景销毁而停止）
	tween.tween_callback(func() -> void:
		SceneTransitionManager.change_scene_to_file("res://Game/UI/UIPanel.tscn")
	)
