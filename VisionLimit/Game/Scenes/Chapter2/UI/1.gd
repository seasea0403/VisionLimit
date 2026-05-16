extends Control

# ==================== 节点引用 ====================
@onready var clue_pool: Control = $CluePool
@onready var slot_a: Panel = $WorkArea/SlotA
@onready var slot_b: Panel = $WorkArea/SlotB
@onready var result_preview: PanelContainer = $WorkArea/ResultPreview
@onready var result_label: Label = $WorkArea/ResultPreview/Label
@onready var reason_button: TextureButton = $WorkArea/UIbutton/TextureButton
@onready var question_log: VBoxContainer = $QuestionLog
@onready var question_log_title: Label = $QuestionLog/LogTitle

@export var question_log_title_text: String = "问题记录"
@export var question_log_title_font: Font
@export var question_log_title_font_size: int = 40
@export var question_log_title_color: Color = Color(1, 1, 1, 1)
@export var question_log_separation: int = 8

@export var question_log_entry_font: Font
@export var question_log_entry_font_size: int = 28
@export var question_log_entry_color: Color = Color(0, 0, 0, 1)
@export var question_log_entry_min_size: Vector2 = Vector2(0, 0)
@export var question_log_entry_spacing: int = 4

# 合成配方：inputs 无序匹配
@export var combinations: Array[Dictionary] = [
	{
		"inputs": ["clue_2", "clue_3"],
		"result_id": "clue_7",
		"result_text": "报道遭压制\n(2046.03)",
		"result_reusable": false,
		"question": "稿件在发布后短时间内被撤回，属于非自然下架，魏江关于苍屿症相关初步报道在3月被压下。",
	},
	{
		"inputs": ["clue_1", "clue_7"],
		"result_id": "clue_8",
		"result_text": "调查遭阻止？\n(2046.03)",
		"result_reusable": false,
		"question": "3月份郑和平的联络人失联和报道被压下，有人在阻止苍屿症的调查？",
	},
	{
		"inputs": ["clue_4", "clue_6"],
		"result_id": "clue_9",
		"result_text": "郑和平采样后\n去向不明",
		"result_reusable": false,
		"question": "郑和平在最后一次采样结束后都做了什么？",
	},
	{
		"inputs": ["clue_6", "clue_8"],
		"result_id": "clue_10",
		"result_text": "郑和平失联\n与调查有关？",
		"result_reusable": false,
		"question": "郑和平的失联与苍屿症的调查有关？",
	},
	{
		"inputs": ["clue_5", "clue_6"],
		"result_id": "clue_11",
		"result_text": "沈意与郑和平\n的秘密",
		"result_reusable": false,
		"question": "沈意到底对郑和平做了什么？",
	},
]

const CLUE_PANEL_SCENE = preload("res://Template/Scene/CluePanel.tscn")

var _solved_count: int = 0

# ==================== 初始化 ====================
func _ready() -> void:
	if clue_pool == null or slot_a == null or slot_b == null or result_preview == null or result_label == null or reason_button == null or question_log == null:
		push_error("Chapter2 UI: 场景节点引用不完整，请检查 1.tscn 的节点路径")
		return

	if clue_pool.get_child_count() == 0:
		push_warning("Chapter2 UI: CluePool 为空，请在 1.tscn 里直接摆放 CluePanel 实例")

	reason_button.pressed.connect(_on_reason_pressed)
	reason_button.disabled = true
	slot_a.slot_updated.connect(_on_slot_updated)
	slot_b.slot_updated.connect(_on_slot_updated)
	result_preview.visible = false

	if question_log_title:
		question_log_title.text = question_log_title_text
		if question_log_title_font:
			question_log_title.add_theme_font_override("font", question_log_title_font)
		question_log_title.add_theme_font_size_override("font_size", question_log_title_font_size)
		question_log_title.add_theme_color_override("font_color", question_log_title_color)
	if question_log:
		question_log.add_theme_constant_override("separation", question_log_separation)

# ==================== 卡槽状态 ====================
func _on_slot_updated() -> void:
	var has_both: bool = slot_a.held_clue_id != "" and slot_b.held_clue_id != ""
	reason_button.disabled = not has_both
	_update_result_preview()


func _update_result_preview() -> void:
	if slot_a.held_clue_id == "" or slot_b.held_clue_id == "":
		result_preview.visible = false
		return

	var combo: Variant = _find_combination(slot_a.held_clue_id, slot_b.held_clue_id)
	result_preview.visible = true
	if combo != null:
		result_label.text = combo["result_text"]
		result_preview.modulate = Color.WHITE
	else:
		result_label.text = "？"
		result_preview.modulate = Color(1.0, 0.55, 0.55)

# ==================== 推理 ====================
func _on_reason_pressed() -> void:
	var id_a: String = slot_a.held_clue_id
	var id_b: String = slot_b.held_clue_id
	var combo: Variant = _find_combination(id_a, id_b)

	if combo == null:
		# 错误：闪红，短暂延迟后归还线索池
		reason_button.disabled = true
		slot_a.flash_error()
		slot_b.flash_error()
		await get_tree().create_timer(0.65).timeout
		slot_a.clear_slot()
		slot_b.clear_slot()
		return

	# 正确：消耗面板，生成结果，记录问题
	reason_button.disabled = true
	_consume_slot(slot_a)
	_consume_slot(slot_b)
	result_preview.visible = false

	_spawn_result_clue(combo["result_id"], combo["result_text"], combo.get("result_reusable", false))
	_record_question(combo["question"])

	_solved_count += 1
	if _solved_count >= combinations.size():
		_on_puzzle_solved()


func _consume_slot(slot: Panel) -> void:
	var panel: Control = slot.release_panel()
	if panel == null:
		return
	if panel.reusable:
		panel.visible = true    # 可复用线索归还线索池
	else:
		panel.queue_free()      # 不可复用线索销毁


func _spawn_result_clue(clue_id: String, text: String, reusable: bool = false) -> void:
	var panel: CluePanel = CLUE_PANEL_SCENE.instantiate()
	if panel == null:
		push_error("Chapter2 UI: 无法实例化结果线索面板")
		return
	clue_pool.add_child(panel)
	panel.setup(clue_id, text, reusable)


func _find_combination(id_a: String, id_b: String) -> Variant:
	var pair := [id_a, id_b]
	pair.sort()
	for combo: Dictionary in combinations:
		var keys: Array = combo["inputs"].duplicate()
		keys.sort()
		if keys == pair:
			return combo
	return null

# ==================== 问题记录 ====================
func _record_question(question: String) -> void:
	var lbl := Label.new()
	lbl.text = "• " + question
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.custom_minimum_size = question_log_entry_min_size
	if question_log_entry_font:
		lbl.add_theme_font_override("font", question_log_entry_font)
	lbl.add_theme_font_size_override("font_size", question_log_entry_font_size)
	lbl.add_theme_color_override("font_color", question_log_entry_color)
	lbl.add_theme_constant_override("line_spacing", question_log_entry_spacing)
	question_log.add_child(lbl)

# ==================== 通关 ====================
func _on_puzzle_solved() -> void:
	# TODO: 连接游戏进度系统，如 GameStateManager.unlock_chapter(3)
	print("[Chapter2] 所有推理完成，谜题解决！")
