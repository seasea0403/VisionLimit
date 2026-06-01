extends "res://Script/Chapters/chapter.gd"

const Ch6Confrontation    = preload("res://Script/Dialogues/ch6_confrontation.gd")
const Ch6SulinPressure    = preload("res://Script/Dialogues/ch6_sulin_pressure.gd")
const PuzzleFixScene      = preload("res://Game/Scenes/Chapter6/puzzle/puzzle_fix.tscn")

const TOTAL_STAGES: int = 7
const FADE_DURATION: float = 1.5

var _current_stage: int = 0
var _stage_item_interacted: bool = false
var _transitioning: bool = false
var _stages: Array = []
var _confrontation_played: bool = false

var _black_overlay: ColorRect
var _overlay_layer: CanvasLayer

func _ready() -> void:
	is_chapter_continuation = true
	chapter_number = 5
	super._ready()

	# 获取所有舞台节点
	_stages = $Stages.get_children()

	# 初始化：只显示第一个舞台，其余全部隐藏
	for i in range(_stages.size()):
		if i == 0:
			_stages[i].visible = true
			_set_stage_items_visible(_stages[i], true)
		else:
			_stages[i].visible = false

	# 监听 ItemDetail 信号
	item_detail.detail_opened.connect(_on_detail_opened)
	if not item_detail.panel_closed.is_connected(_on_panel_closed):
		item_detail.panel_closed.connect(_on_panel_closed)

	# 创建黑屏遮罩层（用于进场亮屏及章节结束暗屏）
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 9
	add_child(_overlay_layer)

	_black_overlay = ColorRect.new()
	_black_overlay.color = Color(0, 0, 0, 1)
	_black_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(_black_overlay)

	# 进场淡出黑屏 + BGM 淡入
	var in_tween = create_tween()
	in_tween.tween_property(_black_overlay, "color", Color(0, 0, 0, 0), 2.0)

	var scene_bgm = get_node_or_null("SceneBgm")
	if scene_bgm:
		scene_bgm.volume_db = -60.0
		if not scene_bgm.playing:
			scene_bgm.play()
		in_tween.parallel().tween_property(scene_bgm, "volume_db", 0.0, 2.0)


# 显示或隐藏一个舞台节点内除 Background 以外的所有子节点（物品）
func _set_stage_items_visible(stage_node: Node, is_visible: bool) -> void:
	for child in stage_node.get_children():
		if child.name != "Background":
			child.visible = is_visible


func _on_detail_opened(_item_id: String) -> void:
	_stage_item_interacted = true
	# Stage6（index 5）：首次点击物品时先播放争执对话，对话结束后再显示详情面板
	if _current_stage == 5 and not _confrontation_played:
		_confrontation_played = true
		item_detail.hide()
		DialogueManager.dialogue_finished.connect(_on_confrontation_finished, CONNECT_ONE_SHOT)
		DialogueManager.start_dialogue(Ch6Confrontation.DATA, "0")


func _on_confrontation_finished() -> void:
	item_detail.show()


func _on_panel_closed() -> void:
	if not _stage_item_interacted or _transitioning:
		return
	_stage_item_interacted = false

	if _current_stage >= TOTAL_STAGES - 1:
		# 最后一个舞台完成：黑屏后显示谜题
		_transitioning = true
		var tween = create_tween()
		tween.tween_property(_black_overlay, "color", Color(0, 0, 0, 1), 1.5)
		tween.tween_callback(_show_puzzle)
	else:
		_advance_stage()


func _advance_stage() -> void:
	_transitioning = true
	var current_node: Node = _stages[_current_stage]
	var next_idx: int = _current_stage + 1
	var next_node: Node = _stages[next_idx]

	# 隐藏当前舞台的物品（背景保留，用于渐隐）
	_set_stage_items_visible(current_node, false)

	# 准备下一舞台：可见但背景完全透明，物品暂时隐藏
	next_node.visible = true
	var next_bg: Node = next_node.get_node_or_null("Background")
	if next_bg:
		next_bg.modulate.a = 0.0
	_set_stage_items_visible(next_node, false)

	# 同时渐隐当前背景、渐显下一背景
	var tween = create_tween()
	var current_bg: Node = current_node.get_node_or_null("Background")
	if current_bg:
		tween.tween_property(current_bg, "modulate:a", 0.0, FADE_DURATION)
	if next_bg:
		tween.parallel().tween_property(next_bg, "modulate:a", 1.0, FADE_DURATION)

	# 切换完成后：隐藏旧舞台，更新索引，显示新舞台物品，解锁交互
	tween.tween_callback(func():
		current_node.visible = false
		_current_stage = next_idx
		_set_stage_items_visible(next_node, true)
		_transitioning = false
	)


func _show_puzzle() -> void:
	# 在新 CanvasLayer 上实例化谜题，layer 高于黑屏遮罩
	_puzzle_layer = CanvasLayer.new()
	_puzzle_layer.layer = 10
	add_child(_puzzle_layer)

	var puzzle = PuzzleFixScene.instantiate()
	_puzzle_layer.add_child(puzzle)
	puzzle.puzzle_completed.connect(_on_puzzle_completed, CONNECT_ONE_SHOT)

	# 淡出黑屏，显示谜题
	var tween = create_tween()
	tween.tween_property(_black_overlay, "color", Color(0, 0, 0, 0), 1.0)


func _on_puzzle_completed() -> void:
	_play_static_to_black(_start_sulin_dialogue)


# ── 雪花特效 + 黑屏 ──────────────────────────────────────────────────────────

var _puzzle_layer: CanvasLayer = null
var _static_layer: CanvasLayer = null

func _play_static_to_black(callback: Callable) -> void:
	_static_layer = CanvasLayer.new()
	_static_layer.layer = 11
	add_child(_static_layer)

	var static_rect := ColorRect.new()
	static_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	static_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_mat := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;\nuniform float intensity : hint_range(0.0, 1.0) = 0.0;\nvoid fragment() {\n\tfloat noise = fract(sin(dot(UV * TIME * 300.0 + vec2(12.9898, 78.233), vec2(127.1, 311.7))) * 43758.5453);\n\tCOLOR = vec4(vec3(noise), intensity);\n}"
	shader_mat.shader = shader
	shader_mat.set_shader_parameter("intensity", 0.0)
	static_rect.material = shader_mat
	_static_layer.add_child(static_rect)

	if is_instance_valid(_puzzle_layer):
		_puzzle_layer.queue_free()
		_puzzle_layer = null

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(func(v: float): shader_mat.set_shader_parameter("intensity", v), 0.0, 1.0, 1.2)
	tween.tween_property(_black_overlay, "color", Color(0, 0, 0, 1), 1.2)
	tween.set_parallel(false)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		_static_layer.queue_free()
		_static_layer = null
		callback.call()
	)


# ── 苏临对话 ─────────────────────────────────────────────────────────────────

func _start_sulin_dialogue() -> void:
	DialogueManager.dialogue_finished.connect(_on_sulin_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6SulinPressure.DATA, "0")


func _on_sulin_dialogue_finished() -> void:
	_play_static_to_black(_goto_chapter5)


func _goto_chapter5() -> void:
	GameStateManager.set_record("ch6_return_from_memory", "1")
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter5/chapter_5.tscn")
