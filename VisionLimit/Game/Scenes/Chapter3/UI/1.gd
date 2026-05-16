extends Control

@onready var title_label: Label = $Center/PhonePanel/Margin/MainVBox/Header/HeaderPad/HeaderRow/TitleStack/TitleLabel
@onready var subtitle_label: Label = $Center/PhonePanel/Margin/MainVBox/Header/HeaderPad/HeaderRow/TitleStack/SubtitleLabel
@onready var progress_label: Label = $Center/PhonePanel/Margin/MainVBox/Header/HeaderPad/HeaderRow/ProgressLabel
@onready var status_label: Label = $Center/PhonePanel/Margin/MainVBox/Footer/FooterPad/FooterRow/StatusLabel
@onready var hint_label: Label = $Center/PhonePanel/Margin/MainVBox/Footer/FooterPad/FooterRow/HintLabel
@onready var board_root: Control = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot
@onready var columns_row: HBoxContainer = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow
@onready var connection_layer: Control = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ConnectionLayer
@onready var complete_overlay: Control = $CompleteOverlay
@onready var complete_desc_label: Label = $CompleteOverlay/Center/CompleteCard/CompletePad/CompleteStack/CompleteDescLabel
@onready var complete_button: Button = $CompleteOverlay/Center/CompleteCard/CompletePad/CompleteStack/ContinueButton

@onready var left_a = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/LeftColumn/ItemA
@onready var left_b = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/LeftColumn/ItemB
@onready var left_c = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/LeftColumn/ItemC
@onready var left_d = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/LeftColumn/ItemD
@onready var right_1 = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/RightColumn/Item1
@onready var right_2 = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/RightColumn/Item2
@onready var right_3 = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/RightColumn/Item3
@onready var right_4 = $Center/PhonePanel/Margin/MainVBox/Board/BoardPad/BoardRoot/ColumnsRow/RightColumn/Item4

@export var title_text: String = "沈意 · 拍照记录"
@export var subtitle_text: String = "点击左侧物证，再点右侧观察项连线；连线可直接点击撤销"
@export var footer_hint_text: String = "左侧物证 → 右侧观察。点选左侧后再点右侧即可连线。"
@export var completion_title_text: String = "拍照记录已完成"
@export var completion_desc_text: String = "四组对应全部正确，可以继续推进第三章。"
@export var completion_chapter_index: int = 3

@export var expected_pairs: Array[Dictionary] = [
	{"left": "A", "right": "4"},
	{"left": "B", "right": "3"},
	{"left": "C", "right": "2"},
	{"left": "D", "right": "1"},
]

@export var line_thickness: float = 16.0
@export var line_corner_radius: int = 8
@export var selected_left_tint: Color = Color(0.98, 0.88, 0.50, 1)
@export var correct_line_color: Color = Color(0.48, 0.86, 0.70, 0.9)
@export var wrong_line_color: Color = Color(0.96, 0.52, 0.52, 0.9)
@export var completed_left_tint: Color = Color(0.74, 0.94, 0.78, 1)
@export var completed_right_tint: Color = Color(0.74, 0.94, 0.78, 1)

var _selected_left_id: String = ""
var _left_to_right: Dictionary = {}
var _right_to_left: Dictionary = {}
var _line_nodes: Dictionary = {}
var _left_cards: Array = []
var _right_cards: Array = []
var _all_cards: Array = []
var _completed: bool = false


func _ready() -> void:
	_left_cards = [left_a, left_b, left_c, left_d]
	_right_cards = [right_1, right_2, right_3, right_4]
	_all_cards = _left_cards.duplicate()
	_all_cards.append_array(_right_cards)

	title_label.text = title_text
	subtitle_label.text = subtitle_text
	progress_label.text = "0 / %d" % expected_pairs.size()
	status_label.text = ""
	hint_label.text = footer_hint_text
	complete_desc_label.text = completion_desc_text
	complete_overlay.visible = false
	connection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for card in _all_cards:
		if card and card.has_signal("card_pressed"):
			card.connect("card_pressed", Callable(self, "_on_card_pressed"))

	if complete_button:
		complete_button.pressed.connect(_on_complete_button_pressed)

	resized.connect(_refresh_all_connection_lines)
	call_deferred("_refresh_all_connection_lines")
	call_deferred("_refresh_card_states")


func _on_card_pressed(item_id: String, side: int) -> void:
	if _completed:
		return

	if side == 0:
		if _selected_left_id == item_id:
			_selected_left_id = ""
			_refresh_card_states()
			_set_status("已取消左侧选择")
			return
		_selected_left_id = item_id
		_refresh_card_states()
		_set_status("已选中左侧物证 %s" % item_id)
		return

	if _selected_left_id == "":
		_set_status("先点左侧物证，再点右侧观察项")
		return

	_connect_pair(_selected_left_id, item_id)
	_selected_left_id = ""
	_refresh_card_states()
	_refresh_all_connection_lines()
	_update_progress()
	_check_completion()


func _connect_pair(left_id: String, right_id: String) -> void:
	if _left_to_right.has(left_id):
		_remove_connection_by_left(left_id)
	if _right_to_left.has(right_id):
		_remove_connection_by_left(str(_right_to_left[right_id]))

	_left_to_right[left_id] = right_id
	_right_to_left[right_id] = left_id

	var line: Panel = _create_connection_line(left_id, right_id)
	connection_layer.add_child(line)
	_line_nodes[left_id] = line

	if _is_pair_correct(left_id, right_id):
		_set_status("%s ↔ %s 连线正确" % [left_id, right_id])
	else:
		_set_status("%s ↔ %s 已连线，但对应不正确，可点击线条撤销" % [left_id, right_id])


func _remove_connection_by_left(left_id: String) -> void:
	if not _left_to_right.has(left_id):
		return

	var right_id: String = str(_left_to_right[left_id])
	_left_to_right.erase(left_id)
	_right_to_left.erase(right_id)

	if _line_nodes.has(left_id):
		var line: Node = _line_nodes[left_id]
		_line_nodes.erase(left_id)
		if is_instance_valid(line):
			line.queue_free()

	_set_status("已撤销 %s ↔ %s" % [left_id, right_id])


func _create_connection_line(left_id: String, right_id: String) -> Panel:
	var line: Panel = Panel.new()
	line.mouse_filter = Control.MOUSE_FILTER_STOP
	line.focus_mode = Control.FOCUS_NONE
	line.z_index = 1
	line.pivot_offset = Vector2(0, line_thickness * 0.5)
	line.custom_minimum_size = Vector2(20, line_thickness)
	line.add_theme_stylebox_override("panel", _make_line_stylebox(_is_pair_correct(left_id, right_id)))
	line.gui_input.connect(Callable(self, "_on_line_gui_input").bind(left_id))
	return line


func _make_line_stylebox(is_correct: bool) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = correct_line_color if is_correct else wrong_line_color
	stylebox.corner_radius_top_left = line_corner_radius
	stylebox.corner_radius_top_right = line_corner_radius
	stylebox.corner_radius_bottom_left = line_corner_radius
	stylebox.corner_radius_bottom_right = line_corner_radius
	return stylebox


func _on_line_gui_input(event: InputEvent, left_id: String) -> void:
	if _completed:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_remove_connection_by_left(left_id)
		_refresh_card_states()
		_refresh_all_connection_lines()
		_update_progress()


func _refresh_all_connection_lines() -> void:
	for left_id in _left_to_right.keys():
		_update_connection_line(str(left_id))


func _update_connection_line(left_id: String) -> void:
	if not _line_nodes.has(left_id):
		return

	var right_id: String = str(_left_to_right[left_id])
	var left_card: Control = _get_card(left_id)
	var right_card: Control = _get_card(right_id)
	var line: Panel = _line_nodes[left_id]
	if left_card == null or right_card == null or line == null:
		return

	var left_rect: Rect2 = left_card.get_global_rect()
	var right_rect: Rect2 = right_card.get_global_rect()
	var start_global: Vector2 = Vector2(left_rect.end.x, left_rect.position.y + left_rect.size.y * 0.5)
	var end_global: Vector2 = Vector2(right_rect.position.x, right_rect.position.y + right_rect.size.y * 0.5)
	var layer_transform: Transform2D = connection_layer.get_global_transform_with_canvas().affine_inverse()
	var start_local: Vector2 = layer_transform * start_global
	var end_local: Vector2 = layer_transform * end_global
	var delta: Vector2 = end_local - start_local
	var length: float = maxf(delta.length(), 1.0)
	line.position = start_local
	line.size = Vector2(length, line_thickness)
	line.pivot_offset = Vector2(0, line_thickness * 0.5)
	line.rotation = delta.angle()
	line.add_theme_stylebox_override("panel", _make_line_stylebox(_is_pair_correct(left_id, right_id)))


func _refresh_card_states() -> void:
	for card in _all_cards:
		if card and card.has_method("set_state"):
			card.call("set_state", 0)

	for left_id in _left_to_right.keys():
		var right_id: String = str(_left_to_right[left_id])
		var state: int = 2 if _is_pair_correct(str(left_id), right_id) else 3
		var left_card: Control = _get_card(str(left_id))
		var right_card: Control = _get_card(right_id)
		if left_card and left_card.has_method("set_state"):
			left_card.call("set_state", state)
		if right_card and right_card.has_method("set_state"):
			right_card.call("set_state", state)

	if _selected_left_id != "":
		var selected_card: Control = _get_card(_selected_left_id)
		if selected_card and selected_card.has_method("set_state"):
			selected_card.call("set_state", 1)


func _update_progress() -> void:
	var correct_count: int = 0
	for pair: Dictionary in expected_pairs:
		var left_id: String = str(pair.get("left", ""))
		var right_id: String = str(pair.get("right", ""))
		if _left_to_right.get(left_id, "") == right_id:
			correct_count += 1
	progress_label.text = "%d / %d" % [correct_count, expected_pairs.size()]


func _check_completion() -> void:
	if _completed:
		return

	for pair: Dictionary in expected_pairs:
		var left_id: String = str(pair.get("left", ""))
		var right_id: String = str(pair.get("right", ""))
		if _left_to_right.get(left_id, "") != right_id:
			return

	_completed = true
	status_label.text = completion_title_text
	complete_desc_label.text = completion_desc_text
	complete_overlay.visible = true
	if has_node("/root/GameStateManager"):
		GameStateManager.complete_chapter(completion_chapter_index)


func _on_complete_button_pressed() -> void:
	complete_overlay.visible = false


func _get_card(item_id: String) -> Control:
	for card: Control in _all_cards:
		if card and card.has_method("get") and str(card.get("item_id")) == item_id:
			return card
	return null


func _is_pair_correct(left_id: String, right_id: String) -> bool:
	for pair: Dictionary in expected_pairs:
		if str(pair.get("left", "")) == left_id:
			return str(pair.get("right", "")) == right_id
	return false


func _set_status(text: String) -> void:
	status_label.text = text
