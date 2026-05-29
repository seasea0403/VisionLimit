extends Control

# ==================== 导出配置 ====================
## 母亲照片的 item_id（仅此 ID 可放入 SlotMother）
@export var mother_item_id: String = "8"
## 父亲照片的 item_id（仅此 ID 可放入 SlotFather）
@export var father_item_id: String = "7"
## 底栏物品格背景纹理（与 InferencePanel 共用 方框.png）
@export var item_bar_slot_texture: Texture2D

# ==================== 子节点引用 ====================
@onready var drop_zone: Control         = $DropZone
@onready var image_mother: TextureRect  = $ImageMother
@onready var image_father: TextureRect  = $ImageFather
@onready var image_complete: TextureRect = $ImageComplete
@onready var item_row: HBoxContainer    = $BottomSection/ItemScroll/ItemRow
@onready var left_arrow: TextureButton  = $BottomSection/LeftArrow
@onready var right_arrow: TextureButton = $BottomSection/RightArrow
@onready var drag_preview: TextureRect  = $DragPreview

# ==================== 状态 ====================
## _placed[0] = 母亲照片槽的 item_id（0=mother, 1=father）
## 空串表示空槽
var _placed: Array[String] = ["", ""]
var _bar_used: Dictionary = {}
var _drag_item_id: String = ""
var _drag_source: int = -2   # -1=底栏, 0=SlotMother, 1=SlotFather
var _is_dragging: bool = false
var _locked: bool = false     # 合成完成后锁定，禁止一切拖拽

# ==================== 信号 ====================
## 摆放状态变化时发出
signal placement_changed(mother_placed: bool, father_placed: bool)
## 两张照片均摆放完成时发出
signal synthesis_complete


# ==================== 初始化 ====================
func _ready() -> void:
	_placed = ["", ""]
	_bar_used = {}
	if left_arrow:
		left_arrow.pressed.connect(_on_left_arrow)
	if right_arrow:
		right_arrow.pressed.connect(_on_right_arrow)
	if drop_zone:
		drop_zone.gui_input.connect(_on_drop_zone_gui_input)
	if drag_preview:
		drag_preview.hide()
	hide()


func open_panel() -> void:
	"""打开合成面板，保留已有摆放状态（不重置），刷新底栏"""
	_update_visuals()
	_refresh_bar()
	show()


func close_panel() -> void:
	"""关闭合成面板，取消当前拖拽"""
	_cancel_drag()
	hide()


func reset_panel() -> void:
	"""重置所有摆放状态（如需从头开始时调用）"""
	_placed = ["", ""]
	_bar_used = {}
	_locked = false
	$BottomSection.show()
	_update_visuals()


func lock() -> void:
	"""合成完成后调用：锁定面板，禁止拖拽，隐藏底栏"""
	_locked = true
	$BottomSection.hide()


func is_complete() -> bool:
	"""返回两张照片是否均已摆放完成"""
	return _placed[0] == mother_item_id and _placed[1] == father_item_id


# ==================== 底栏刷新 ====================
func _refresh_bar() -> void:
	for child in item_row.get_children():
		child.queue_free()

	var items: Dictionary = GameStateManager.get_inventory_items()
	for item_id in items.keys():
		var data: Dictionary = items[item_id]

		var slot_btn := PanelContainer.new()
		slot_btn.custom_minimum_size = Vector2(108, 108)

		if item_bar_slot_texture:
			var style := StyleBoxTexture.new()
			style.texture = item_bar_slot_texture
			style.set_content_margin_all(6.0)
			slot_btn.add_theme_stylebox_override("panel", style)

		var thumb := TextureRect.new()
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
	if _locked:
		return
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if _bar_used.get(item_id, false):
			return
		_start_drag(item_id, -1)


# ==================== 统一放置区交互（从已放入槽拖起）====================
func _on_drop_zone_gui_input(event: InputEvent) -> void:
	if _is_dragging or _locked:
		return
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		# 按 mother → father 顺序，找到第一个已放置的物品并拖起
		for i in range(_placed.size()):
			if _placed[i] != "":
				var item_id: String = _placed[i]
				_placed[i] = ""
				_bar_used[item_id] = false
				_update_visuals()
				_start_drag(item_id, i)
				_emit_placement_changed()
				return


# ==================== 拖拽核心 ====================
func _start_drag(item_id: String, source: int) -> void:
	_drag_item_id = item_id
	_drag_source = source
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
	# 归还到原槽位
	if _drag_source >= 0:
		_placed[_drag_source] = _drag_item_id
		_bar_used[_drag_item_id] = true
		_update_bar_dim(_drag_item_id, true)
		_update_visuals()
	_is_dragging = false
	_drag_item_id = ""
	_drag_source = -2
	if drag_preview:
		drag_preview.hide()


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
	# 统一识别区：拖入即根据 item_id 自动路由到对应槽位
	if not drop_zone.get_global_rect().has_point(drop_pos):
		_cancel_drag()
		return

	var target_slot: int = -1
	if _drag_item_id == mother_item_id:
		target_slot = 0
	elif _drag_item_id == father_item_id:
		target_slot = 1
	else:
		_cancel_drag()
		return

	# 松开在来源槽上 = 归还底栏
	if _drag_source == target_slot:
		_placed[target_slot] = ""
		_bar_used[_drag_item_id] = false
		_update_bar_dim(_drag_item_id, false)
		_is_dragging = false
		_drag_item_id = ""
		_drag_source = -2
		drag_preview.hide()
		_update_visuals()
		_emit_placement_changed()
		return

	# 清空来源槽（来自另一槽位）
	if _drag_source >= 0:
		_placed[_drag_source] = ""
	else:
		# 来自底栏：标记已使用
		_bar_used[_drag_item_id] = true
		_update_bar_dim(_drag_item_id, true)

	_placed[target_slot] = _drag_item_id
	_is_dragging = false
	_drag_item_id = ""
	_drag_source = -2
	drag_preview.hide()
	_update_visuals()
	_emit_placement_changed()


# ==================== 视觉更新 ====================
func _update_visuals() -> void:
	var mother_placed: bool = _placed[0] == mother_item_id
	var father_placed: bool = _placed[1] == father_item_id
	var both: bool = mother_placed and father_placed

	# 单独摆放时只显示对应照片；两者均摆放时只显示合成完整图
	if image_mother:
		image_mother.visible = mother_placed and not both
	if image_father:
		image_father.visible = father_placed and not both
	if image_complete:
		image_complete.visible = both


func _update_bar_dim(item_id: String, dimmed: bool) -> void:
	for child in item_row.get_children():
		if child.get_meta("item_id", "") == item_id:
			var dim: ColorRect = child.get_node_or_null("DimOverlay") as ColorRect
			if dim:
				dim.visible = dimmed
			break


# ==================== 完成检测 ====================
func _emit_placement_changed() -> void:
	var mother_placed: bool = _placed[0] == mother_item_id
	var father_placed: bool = _placed[1] == father_item_id
	placement_changed.emit(mother_placed, father_placed)
	if mother_placed and father_placed:
		synthesis_complete.emit()


# ==================== 箭头滚动 ====================
func _on_left_arrow() -> void:
	var scroll: ScrollContainer = item_row.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_horizontal = max(0, scroll.scroll_horizontal - 120)


func _on_right_arrow() -> void:
	var scroll: ScrollContainer = item_row.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_horizontal += 120
