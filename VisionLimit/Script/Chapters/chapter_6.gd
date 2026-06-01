extends "res://Script/Chapters/chapter.gd"

const Ch5Memory = preload("res://Script/Dialogues/ch5_memory.gd")

var _items_collected = {
	"1": false, # block
	"2": false, # cup
	"3": false, # hardcore
	"4": false, # keyboard
	"video": false
}

var _all_collected: bool = false
var _black_overlay: ColorRect
var _overlay_layer: CanvasLayer

func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(6)
	GameStateManager.reset_chapter_items(6)
	item_detail.detail_opened.connect(_on_detail_opened)
	
	# 这里监听玩家自己关闭详情面板的信号
	if not item_detail.panel_closed.is_connected(_on_panel_closed):
		item_detail.panel_closed.connect(_on_panel_closed)
	
	# Hook into the video panel to know when the video finishes
	var video_panel = get_node_or_null("items/ClickableVideo/VideoPanel")
	if video_panel and video_panel.has_node("VideoPlayer"):
		video_panel.get_node("VideoPlayer").finished.connect(_on_video_finished)
		
	# 创建一个CanvasLayer，位于UI和对话层之间（对话层 DialoguePanel 为 10）
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 9
	add_child(_overlay_layer)

	# 创建一个全屏黑色遮罩，用于进场亮屏及记忆完毕后的暗屏
	_black_overlay = ColorRect.new()
	_black_overlay.color = Color(0, 0, 0, 1) # 初始设置为全黑
	_black_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(_black_overlay)

	# 进场淡出黑屏（黑屏渐透）及BGM淡入
	var in_tween = create_tween()
	in_tween.tween_property(_black_overlay, "color", Color(0, 0, 0, 0), 2.0)
	
	var scene_bgm = get_node_or_null("SceneBgm")
	if scene_bgm:
		scene_bgm.volume_db = -60.0
		if not scene_bgm.playing:
			scene_bgm.play()
		in_tween.parallel().tween_property(scene_bgm, "volume_db", 0.0, 2.0)

func _on_detail_opened(item_id: String) -> void:
	if _items_collected.has(item_id):
		if not _items_collected[item_id]:
			_items_collected[item_id] = true
			_check_all_collected()

func _on_video_finished() -> void:
	if not _items_collected["video"]:
		_items_collected["video"] = true
		_check_all_collected()

func _check_all_collected() -> void:
	for key in _items_collected:
		if not _items_collected[key]:
			return
	_all_collected = true
	# 仅标记完成，不在这里强制关闭，而是等待玩家主动关闭 item_detail

func _on_panel_closed() -> void:
	if _all_collected:
		_all_collected = false # 防止重复触发
		# 所有物件集齐，并且玩家点击了返回按钮关闭了详情面板后，触发淡出动画和独白
		var tween = create_tween()
		tween.tween_property(_black_overlay, "color", Color(0, 0, 0, 1), 2.0)
		tween.tween_callback(_start_memory_dialogue)

func _start_memory_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_memory_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_memory_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch5Memory.DATA, "0")

func _on_memory_dialogue_finished() -> void:
	# 设置第五章已收集过记忆的标志
	GameStateManager.set_record("ch5_memory_completed", "1")
	# 返回第五章
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter5/chapter_5.tscn")
