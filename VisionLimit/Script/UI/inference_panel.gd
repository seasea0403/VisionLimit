extends Control

signal inference_success
signal inference_fail
signal chapter_next_requested
signal chapter_holdon_requested

# ==================== 导出配置 ====================
## 推理板方框纹理（推理板方框.png）
@export var slot_frame_texture: Texture2D
## 底栏物品格纹理（方框.png）
@export var item_bar_slot_texture: Texture2D
## 本关正确答案（item_id 数组，顺序不限）
@export var correct_items: Array[String] = []

# ==================== 子节点引用 ====================
@onready var close_btn: TextureButton = $PanelAnchor/CloseBtn
@onready var item_scroll: ScrollContainer = $PanelAnchor/BottomSection/ItemScroll
@onready var item_row: HBoxContainer = $PanelAnchor/BottomSection/ItemScroll/ItemRow
@onready var left_arrow: TextureButton = $PanelAnchor/BottomSection/LeftArrow
@onready var right_arrow: TextureButton = $PanelAnchor/BottomSection/RightArrow
@onready var submit_btn: Button = $PanelAnchor/SubmitBtn
@onready var feedback_label: Label = $PanelAnchor/FeedbackLabel
@onready var drag_preview: TextureRect = $DragPreview
@onready var _next_btn_container: Control = $NextButton
@onready var _holdon_btn_container: Control = $HoldonButton
@onready var _finish_container: Control = $Finish

# ==================== 状态 ====================
var _slots: Array[Control] = []
var _placed: Array[String] = ["", "", "", "", ""]   # 每槽 item_id，空=""
var _bar_used: Dictionary = {}                       # item_id → bool（是否已放入槽）

# 拖拽状态
var _drag_item_id: String = ""
var _drag_source_slot: int = -2   # -1=来自底栏，0-4=来自某槽位
var _is_dragging: bool = false


# ==================== 初始化 ====================
func _ready() -> void:
	close_btn.pressed.connect(close_panel)
	left_arrow.pressed.connect(_on_left_arrow_pressed)
	right_arrow.pressed.connect(_on_right_arrow_pressed)
	submit_btn.pressed.connect(_on_submit_pressed)
	submit_btn.hide()
	feedback_label.hide()
	drag_preview.hide()
	drag_preview.z_index = 100
	_next_btn_container.hide()
	_holdon_btn_container.hide()
	_finish_container.hide()
	$NextButton/TextureButton.pressed.connect(_on_next_btn_pressed)
	$HoldonButton/TextureButton.pressed.connect(_on_holdon_btn_pressed)

	for i in range(5):
		var slot: Control = $PanelAnchor/BoardSection.get_node("Slot%d" % i) as Control
		_slots.append(slot)
		slot.gui_input.connect(_on_slot_gui_input.bind(i))

	hide()


func set_correct_items(items: Array[String]) -> void:
	correct_items = items


func open_panel() -> void:
	_refresh_bar()
	show()


func close_panel() -> void:
	_cancel_drag()
	hide()


# ==================== 底栏刷新 ====================
func _refresh_bar() -> void:
	for child in item_row.get_children():
		child.queue_free()

	var items: Dictionary = GameStateManager.get_inventory_items()
	for item_id in items:
		var data: Dictionary = items[item_id]
		var slot_btn := PanelContainer.new()
		slot_btn.custom_minimum_size = Vector2(108, 108)

		if item_bar_slot_texture:
			var style := StyleBoxTexture.new()
			style.texture = item_bar_slot_texture
			style.set_content_margin_all(6.0)
			slot_btn.add_theme_stylebox_override("panel", style)

		var thumb := TextureRect.new()
		thumb.name = "Thumb"
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		thumb.texture = data.get("thumbnail", null)
		thumb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_btn.add_child(thumb)

		var dim := ColorRect.new()
		dim.name = "DimOverlay"
		dim.color = Color(0.0, 0.0, 0.0, 0.55)
		dim.visible = _bar_used.get(item_id, false)
		dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_btn.add_child(dim)

		slot_btn.set_meta("item_id", item_id)
		slot_btn.gui_input.connect(_on_bar_item_gui_input.bind(item_id))
		item_row.add_child(slot_btn)


func _on_bar_item_gui_input(event: InputEvent, item_id: String) -> void:
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if _bar_used.get(item_id, false):
			return
		_start_drag(item_id, -1)


# ==================== 槽位交互（从槽位拖起） ====================
func _on_slot_gui_input(event: InputEvent, slot_idx: int) -> void:
	if _is_dragging:
		return
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		var item_id: String = _placed[slot_idx]
		if item_id == "":
			return
		_placed[slot_idx] = ""
		_update_slot_visual(slot_idx)
		_check_submit_visibility()
		_start_drag(item_id, slot_idx)


# ==================== 拖拽核心 ====================
func _start_drag(item_id: String, source_slot: int) -> void:
	_drag_item_id = item_id
	_drag_source_slot = source_slot
	_is_dragging = true

	var items: Dictionary = GameStateManager.get_inventory_items()
	var thumb: Texture2D = null
	if items.has(item_id):
		thumb = items[item_id].get("thumbnail", null)

	drag_preview.texture = thumb
	drag_preview.size = Vector2(90.0, 90.0)
	drag_preview.pivot_offset = Vector2(45.0, 45.0)
	drag_preview.position = get_viewport().get_mouse_position() - Vector2(45.0, 45.0)
	drag_preview.show()
	drag_preview.move_to_front()


func _cancel_drag() -> void:
	if not _is_dragging:
		return
	if _drag_source_slot >= 0:
		# 归还到原槽位
		_placed[_drag_source_slot] = _drag_item_id
		_update_slot_visual(_drag_source_slot)
		_bar_used[_drag_item_id] = true
		_update_bar_dim(_drag_item_id, true)
	# 来自底栏则不做处理（物品本来就在栏中）
	_is_dragging = false
	_drag_item_id = ""
	_drag_source_slot = -2
	drag_preview.hide()
	_check_submit_visibility()


func _input(event: InputEvent) -> void:
	if not visible or not _is_dragging:
		return
	if event is InputEventMouseMotion:
		drag_preview.position = event.position - Vector2(45.0, 45.0)
	elif event is InputEventMouseButton \
			and not event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_try_drop(event.position)


func _try_drop(drop_pos: Vector2) -> void:
	for i in range(_slots.size()):
		if _slots[i].get_global_rect().has_point(drop_pos):
			# 松开位置 = 来源槽：单纯点击取消放置，物品归还底栏
			if _drag_source_slot == i:
				_bar_used[_drag_item_id] = false
				_update_bar_dim(_drag_item_id, false)
				_is_dragging = false
				_drag_item_id = ""
				_drag_source_slot = -2
				drag_preview.hide()
				_check_submit_visibility()
				return

			var existing: String = _placed[i]
			if existing != "":
				# 原有物品弹回底栏
				_bar_used[existing] = false
				_update_bar_dim(existing, false)

			if _drag_source_slot >= 0:
				# 来自另一个槽：清空原槽
				_placed[_drag_source_slot] = ""
				_update_slot_visual(_drag_source_slot)
			else:
				# 来自底栏：标记已使用
				_bar_used[_drag_item_id] = true
				_update_bar_dim(_drag_item_id, true)

			_place_in_slot(_drag_item_id, i)
			_is_dragging = false
			_drag_item_id = ""
			_drag_source_slot = -2
			drag_preview.hide()
			_check_submit_visibility()
			return

	# 未落在任何槽上
	_cancel_drag()


# ==================== 槽位内容操作 ====================
func _place_in_slot(item_id: String, slot_idx: int) -> void:
	_placed[slot_idx] = item_id
	_update_slot_visual(slot_idx)


func _update_slot_visual(slot_idx: int) -> void:
	var slot: Control = _slots[slot_idx]
	var thumb_rect: TextureRect = slot.get_node_or_null("ThumbRect") as TextureRect
	if not thumb_rect:
		return
	var item_id: String = _placed[slot_idx]
	if item_id == "":
		thumb_rect.texture = null
	else:
		var items: Dictionary = GameStateManager.get_inventory_items()
		if items.has(item_id):
			thumb_rect.texture = items[item_id].get("thumbnail", null)


func _update_bar_dim(item_id: String, dimmed: bool) -> void:
	for child in item_row.get_children():
		if child.get_meta("item_id", "") == item_id:
			var dim: ColorRect = child.get_node_or_null("DimOverlay") as ColorRect
			if dim:
				dim.visible = dimmed
			break


func _check_submit_visibility() -> void:
	var all_filled := true
	for p in _placed:
		if p == "":
			all_filled = false
			break
	submit_btn.visible = all_filled


# ==================== 提交逻辑 ====================
func _on_submit_pressed() -> void:
	var placed_set: Dictionary = {}
	for p in _placed:
		if p != "":
			placed_set[p] = true

	var correct := true
	if correct_items.size() == 0 or placed_set.size() != correct_items.size():
		correct = false
	else:
		for ci in correct_items:
			if not placed_set.has(ci):
				correct = false
				break

	if correct:
		_show_feedback(true)
		inference_success.emit()
	else:
		_show_feedback(false)
		_clear_all_slots()
		inference_fail.emit()


func _show_feedback(success: bool) -> void:
	feedback_label.show()
	if success:
		feedback_label.text = "提交成功"
		feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
		for slot in _slots:
			var flash: ColorRect = slot.get_node_or_null("HighlightFlash") as ColorRect
			if flash:
				flash.show()
		await get_tree().create_timer(1.5).timeout
		if not is_instance_valid(self):
			return
		for slot in _slots:
			var flash: ColorRect = slot.get_node_or_null("HighlightFlash") as ColorRect
			if flash:
				flash.hide()
	else:
		feedback_label.text = "提交失败，请整理线索后重新提交"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
		await get_tree().create_timer(2.0).timeout
		if not is_instance_valid(self):
			return
		feedback_label.hide()


func _clear_all_slots() -> void:
	for i in range(_placed.size()):
		var item_id: String = _placed[i]
		if item_id != "":
			_bar_used[item_id] = false
			_update_bar_dim(item_id, false)
		_placed[i] = ""
		_update_slot_visual(i)
	submit_btn.hide()


# ==================== 完成按钮 ====================
func show_completion_buttons() -> void:
	_next_btn_container.show()
	_holdon_btn_container.show()
	_finish_container.show()
	submit_btn.hide()
	show()


func _on_next_btn_pressed() -> void:
	chapter_next_requested.emit()


func _on_holdon_btn_pressed() -> void:
	chapter_holdon_requested.emit()
	close_panel()


# ==================== 底栏滚动 ====================
func _on_left_arrow_pressed() -> void:
	item_scroll.scroll_horizontal = max(0, item_scroll.scroll_horizontal - 120)


func _on_right_arrow_pressed() -> void:
	item_scroll.scroll_horizontal += 120
