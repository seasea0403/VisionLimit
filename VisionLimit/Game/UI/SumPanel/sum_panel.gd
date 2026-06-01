extends Control

# ==================== 导出配置（Inspector 中可调）====================
## 格子边框纹理（IMG_3330.PNG）
@export var slot_frame_texture: Texture2D
## 单个槽位大小
@export var slot_size: Vector2 = Vector2(110, 110)
## 每页显示的槽位数量（超出后翻页）
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
@onready var left_section: Control = $PanelAnchor/LeftSection
@onready var right_section: Control = $PanelAnchor/RightSection
@onready var tab1_btn: Button = $PanelAnchor/Tab1Btn
@onready var tab2_btn: Button = $PanelAnchor/Tab2Btn
@onready var page2: Control = $PanelAnchor/Page2

# ==================== 状态 ====================
var _selected_item_id: String = ""
## item_id → PanelContainer（只有已填入物品的格子才在此记录）
var _slot_nodes: Dictionary = {}
var _current_page: int = 1  # 1=物品页  2=记录页
## 物品页当前所在的页码（0 起始）
var _item_page: int = 0
## 当前在物品栏中查看的章节编号
var _viewing_chapter: int = 1

# ==================== 章节导航（节点引用）====================
@onready var _chapter_prev_btn: Button = $PanelAnchor/LeftSection/ChapterNavRow/PrevBtn
@onready var _chapter_next_btn: Button = $PanelAnchor/LeftSection/ChapterNavRow/NextBtn
@onready var _chapter_label: Label = $PanelAnchor/LeftSection/ChapterNavRow/ChapterLabel


# ==================== 初始化 ====================
func _ready() -> void:
	close_btn.pressed.connect(close_panel)
	up_btn.pressed.connect(_on_up_pressed)
	down_btn.pressed.connect(_on_down_pressed)
	tab1_btn.pressed.connect(_switch_to_page.bind(1))
	tab2_btn.pressed.connect(_switch_to_page.bind(2))

	if not GameStateManager.item_added_to_inventory.is_connected(_on_item_added):
		GameStateManager.item_added_to_inventory.connect(_on_item_added)

	if is_instance_valid(_chapter_prev_btn):
		_chapter_prev_btn.pressed.connect(_on_chapter_prev_pressed)
	if is_instance_valid(_chapter_next_btn):
		_chapter_next_btn.pressed.connect(_on_chapter_next_pressed)

	_switch_to_page(1)
	hide()


# ==================== 面板开关 ====================
func open_panel() -> void:
	_viewing_chapter = GameStateManager.get_current_chapter()
	if _viewing_chapter <= 0:
		_viewing_chapter = 1
	show()
	_refresh_slots()
	_update_chapter_nav()


func open_and_select(item_id: String) -> void:
	"""由 ClickableItem 点击时调用：切换到物品页并选中指定物品"""
	_switch_to_page(1)
	_viewing_chapter = GameStateManager.get_current_chapter()
	if _viewing_chapter <= 0:
		_viewing_chapter = 1
	# 先定位到该物品所在页码
	var items := GameStateManager.get_inventory_items_for_chapter(_viewing_chapter)
	if item_id in items:
		var idx: int = items.keys().find(item_id)
		_item_page = idx / total_slots
	show()
	_refresh_slots()
	_update_chapter_nav()
	if item_id in GameStateManager.get_inventory_items_for_chapter(_viewing_chapter):
		_select_slot(item_id)


func close_panel() -> void:
	hide()


# ==================== 收到新物品信号 ====================
func _on_item_added(_item_id: String) -> void:
	if visible:
		_refresh_slots()


# ==================== 刷新所有槽位（翻页模式）====================
# 每页固定渲染 total_slots 个格子，只展示当前页对应的物品
func _refresh_slots() -> void:
	for child in slot_grid.get_children():
		child.queue_free()
	_slot_nodes.clear()

	var items := GameStateManager.get_inventory_items_for_chapter(_viewing_chapter)
	var item_ids: Array = items.keys()  # 按收集顺序

	# 修正页码越界
	var max_page: int = max(0, (item_ids.size() - 1) / total_slots) if item_ids.size() > 0 else 0
	_item_page = clamp(_item_page, 0, max_page)

	var start: int = _item_page * total_slots

	for i in range(total_slots):
		var idx: int = start + i
		if idx < item_ids.size():
			_add_filled_slot(item_ids[idx], items[item_ids[idx]])
		else:
			_add_empty_slot()

	# 更新翻页按钮状态
	up_btn.disabled = (_item_page == 0)
	down_btn.disabled = (_item_page >= max_page)

	# 恢复选中状态（仅当选中物品在当前查看章节时显示高亮）
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
	var items := GameStateManager.get_inventory_items_for_chapter(_viewing_chapter)
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


# ==================== 翻页控制 ====================
func _on_up_pressed() -> void:
	if _item_page > 0:
		_item_page -= 1
		_refresh_slots()


func _on_down_pressed() -> void:
	var item_count: int = GameStateManager.get_inventory_items_for_chapter(_viewing_chapter).size()
	var max_page: int = max(0, (item_count - 1) / total_slots) if item_count > 0 else 0
	if _item_page < max_page:
		_item_page += 1
		_refresh_slots()


# ==================== 章节导航 ====================
func _update_chapter_nav() -> void:
	"""根据 _viewing_chapter 刷新章节标签及左右按钮可用状态"""
	if not is_instance_valid(_chapter_label):
		return
	_chapter_label.text = "第%d章" % _viewing_chapter
	_chapter_prev_btn.disabled = (_viewing_chapter <= 1)
	_chapter_next_btn.disabled = (
		_viewing_chapter >= GameStateManager.current_unlocked_chapter
	)


func _on_chapter_prev_pressed() -> void:
	if _viewing_chapter > 1:
		_viewing_chapter -= 1
		_item_page = 0
		_refresh_slots()
		_update_chapter_nav()


func _on_chapter_next_pressed() -> void:
	if _viewing_chapter < GameStateManager.current_unlocked_chapter:
		_viewing_chapter += 1
		_item_page = 0
		_refresh_slots()
		_update_chapter_nav()


# ==================== 页面切换 ====================
func _switch_to_page(page: int) -> void:
	_current_page = page
	left_section.visible = (page == 1)
	right_section.visible = (page == 1)
	page2.visible = (page == 2)
	if page == 2 and page2.has_method("on_page_opened"):
		page2.call("on_page_opened")


# ==================== 记录页：外部调用入口 ====================
func add_record_entry(key: String, title: String, description: String) -> void:
	if page2.has_method("add_record_entry"):
		page2.call("add_record_entry", key, title, description)
