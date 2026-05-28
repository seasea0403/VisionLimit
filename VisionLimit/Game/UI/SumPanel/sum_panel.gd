extends Control

# ==================== 导出配置（Inspector 中可调）====================
## 格子边框纹理（IMG_3330.PNG）
@export var slot_frame_texture: Texture2D
## 单个槽位大小
@export var slot_size: Vector2 = Vector2(110, 110)
## 上/下箭头每次滚动像素量
@export var scroll_step: float = 120.0
## 预设空白槽位总数（从一开始就显示这么多格子）
@export var total_slots: int = 10

# ==================== 子节点引用 ====================
@onready var close_btn: TextureButton = $PanelAnchor/CloseBtn
@onready var up_btn: Button = $PanelAnchor/LeftSection/UpBtn
@onready var down_btn: Button = $PanelAnchor/LeftSection/DownBtn
@onready var slot_scroll: ScrollContainer = $PanelAnchor/LeftSection/SlotScroll
@onready var slot_grid: GridContainer = $PanelAnchor/LeftSection/SlotScroll/SlotGrid
@onready var item_name: Label = $PanelAnchor/RightSection/ItemName
@onready var item_image: TextureRect = $PanelAnchor/RightSection/ItemImage
@onready var item_desc: Label = $PanelAnchor/RightSection/ItemDescScroll/ItemDesc

# ==================== 状态 ====================
var _selected_item_id: String = ""
## item_id → PanelContainer（只有已填入物品的格子才在此记录）
var _slot_nodes: Dictionary = {}


# ==================== 初始化 ====================
func _ready() -> void:
	close_btn.pressed.connect(close_panel)
	up_btn.pressed.connect(_on_up_pressed)
	down_btn.pressed.connect(_on_down_pressed)

	if not GameStateManager.item_added_to_inventory.is_connected(_on_item_added):
		GameStateManager.item_added_to_inventory.connect(_on_item_added)

	hide()


# ==================== 面板开关 ====================
func open_panel() -> void:
	show()
	_refresh_slots()


func close_panel() -> void:
	hide()


# ==================== 收到新物品信号 ====================
func _on_item_added(_item_id: String) -> void:
	if visible:
		_refresh_slots()


# ==================== 刷新所有槽位 ====================
# 始终渲染 total_slots 个格子：前面已收集的填上缩略图，剩余为空白
func _refresh_slots() -> void:
	for child in slot_grid.get_children():
		child.queue_free()
	_slot_nodes.clear()

	var items := GameStateManager.get_inventory_items()
	var item_ids: Array = items.keys()  # 按收集顺序

	for i in range(total_slots):
		if i < item_ids.size():
			_add_filled_slot(item_ids[i], items[item_ids[i]])
		else:
			_add_empty_slot()

	# 恢复选中状态
	if _selected_item_id in items:
		_show_detail(_selected_item_id)
	else:
		_selected_item_id = ""
		_clear_detail()


# ==================== 创建已填入物品的槽位 ====================
func _add_filled_slot(item_id: String, data: Dictionary) -> void:
	var slot := _make_slot_container()

	# 物品缩略图
	var thumb_rect := TextureRect.new()
	thumb_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb_rect.texture = data.get("thumbnail", null)
	thumb_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	thumb_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(thumb_rect)

	# 选中高亮层
	var highlight := ColorRect.new()
	highlight.name = "Highlight"
	highlight.color = Color(1.0, 1.0, 0.4, 0.28)
	highlight.visible = (item_id == _selected_item_id)
	highlight.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(highlight)

	slot.gui_input.connect(_on_slot_input.bind(item_id))

	slot_grid.add_child(slot)
	_slot_nodes[item_id] = slot


# ==================== 创建空白槽位 ====================
func _add_empty_slot() -> void:
	var slot := _make_slot_container()
	slot_grid.add_child(slot)


# ==================== 公共槽位容器构建 ====================
func _make_slot_container() -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = slot_size
	if slot_frame_texture:
		var style := StyleBoxTexture.new()
		style.texture = slot_frame_texture
		style.set_content_margin_all(6.0)
		slot.add_theme_stylebox_override("panel", style)
	return slot


func _on_slot_input(event: InputEvent, item_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_slot(item_id)


func _select_slot(item_id: String) -> void:
	# 取消旧选中高亮
	if _selected_item_id in _slot_nodes:
		var hl: Node = _slot_nodes[_selected_item_id].get_node_or_null("Highlight")
		if hl:
			hl.visible = false

	_selected_item_id = item_id

	# 新选中高亮
	if item_id in _slot_nodes:
		var hl: Node = _slot_nodes[item_id].get_node_or_null("Highlight")
		if hl:
			hl.visible = true

	_show_detail(item_id)


# ==================== 显示右侧详情 ====================
func _show_detail(item_id: String) -> void:
	var items := GameStateManager.get_inventory_items()
	if not items.has(item_id):
		return
	var data: Dictionary = items[item_id]
	item_name.text = data.get("name", "")
	item_desc.text = data.get("description", "")
	item_image.texture = data.get("thumbnail", null)


func _clear_detail() -> void:
	item_name.text = ""
	item_desc.text = ""
	item_image.texture = null


# ==================== 滚动控制 ====================
func _on_up_pressed() -> void:
	slot_scroll.scroll_vertical = max(0, slot_scroll.scroll_vertical - int(scroll_step))


func _on_down_pressed() -> void:
	slot_scroll.scroll_vertical += int(scroll_step)
