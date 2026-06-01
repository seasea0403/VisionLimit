extends Control

# ==================== 导出配置 ====================
## 用于解锁抽屉的物品 ID（钥匙）
@export var key_item_id: String = "18"
## 底栏物品格背景纹理
@export var item_bar_slot_texture: Texture2D

# ==================== 子节点引用 ====================
@onready var drop_zone: Control        = $DropZone
@onready var item_row: HBoxContainer   = $BottomSection/ItemScroll/ItemRow
@onready var left_arrow: TextureButton = $BottomSection/LeftArrow
@onready var right_arrow: TextureButton = $BottomSection/RightArrow
@onready var drag_preview: TextureRect = $DragPreview

# ==================== 信号 ====================
## 成功将钥匙拖入放置区时发出
signal unlock_success

# ==================== 状态 ====================
var _is_dragging: bool = false
var _drag_item_id: String = ""


# ==================== 初始化 ====================
func _ready() -> void:
	if left_arrow:
		left_arrow.pressed.connect(_on_left_arrow)
	if right_arrow:
		right_arrow.pressed.connect(_on_right_arrow)
	if drag_preview:
		drag_preview.hide()
	hide()


func open_panel() -> void:
	"""打开面板，刷新底栏物品"""
	_refresh_bar()
	show()


func close_panel() -> void:
	"""关闭面板（back 按钮或解锁完成后调用）"""
	_cancel_drag()
	hide()


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

		slot_btn.set_meta("item_id", item_id)
		slot_btn.gui_input.connect(_on_bar_item_gui_input.bind(item_id))
		item_row.add_child(slot_btn)


func _on_bar_item_gui_input(event: InputEvent, item_id: String) -> void:
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_start_drag(item_id)


# ==================== 拖拽核心 ====================
func _start_drag(item_id: String) -> void:
	_drag_item_id = item_id
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
	_is_dragging = false
	_drag_item_id = ""
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
	if not drop_zone.get_global_rect().has_point(drop_pos):
		_cancel_drag()
		return

	if _drag_item_id != key_item_id:
		_cancel_drag()
		return

	# 成功将钥匙放入放置区
	_is_dragging = false
	_drag_item_id = ""
	if drag_preview:
		drag_preview.hide()
	unlock_success.emit()


# ==================== 箭头滚动 ====================
func _on_left_arrow() -> void:
	var scroll: ScrollContainer = item_row.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_horizontal = max(0, scroll.scroll_horizontal - 120)


func _on_right_arrow() -> void:
	var scroll: ScrollContainer = item_row.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_horizontal += 120
