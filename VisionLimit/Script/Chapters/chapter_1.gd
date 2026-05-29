extends Node2D

# ==================== HUD 控制规范 ====================
# HUDPanel 的按钮统一控制场景导航：
# - back 按钮：优先关闭 ItemDetail，其次关闭当前打开的 ZoomView
# - book 按钮：打开 RecordPanel

@onready var item_detail = $UILayer/ItemDetail
@onready var zoom_views_root = $ZoomViews
@onready var clickable_areas = $ZoomViews.get_children()
@onready var ui_layer = $UILayer
@onready var hud_back_button = $UILayer/HudPanel/back/TextureButton
@onready var hud_book_button = $UILayer/HudPanel/book/TextureButton

var record_panel: Control
var sum_panel: Control
var open_panels: Array[Control] = []

func register_panel_open(panel: Control) -> void:
	if panel not in open_panels:
		open_panels.append(panel)

func _ready():
	# 可点击区域必须可见，否则 input_event 不会触发
	zoom_views_root.show()
	for area in clickable_areas:
		area.show()
		# 仅隐藏每个区域里的放大视图，不隐藏可点击区域本体
		for child in area.get_children():
			if child.has_method("hide_view"):
				child.hide_view()

	item_detail.hide() # 隐藏详情面板
	_setup_record_panel()
	_setup_sum_panel()
	# 连接 HUD 物品按钮
	var hud_items_btn := get_node_or_null("UILayer/HudPanel/items/TextureButton") as BaseButton
	if hud_items_btn and not hud_items_btn.pressed.is_connected(_on_hud_items_pressed):
		hud_items_btn.pressed.connect(_on_hud_items_pressed)
	
	# 连接 ItemDetail 的记录信号
	if item_detail and item_detail.has_signal("item_recorded"):
		if not item_detail.item_recorded.is_connected(_on_item_recorded):
			item_detail.item_recorded.connect(_on_item_recorded)
	
	# 连接 HUDPanel 按钮
	if hud_back_button:
		hud_back_button.pressed.connect(_on_hud_back_pressed)
	if hud_book_button:
		hud_book_button.pressed.connect(_on_hud_book_pressed)
	print("Chapter1 场景已准备好：ClickableArea 可见，ZoomView 已隐藏")


func _setup_record_panel() -> void:
	record_panel = ui_layer.find_child("RecordPanel", true, false) as Control
	if record_panel:
		return
	var record_panel_scene := load("res://Game/UI/RecordPanel/RecordPanel.tscn")
	if not record_panel_scene:
		return
	record_panel = record_panel_scene.instantiate() as Control
	if not record_panel:
		return
	record_panel.name = "RecordPanel"
	ui_layer.add_child(record_panel)


func _setup_sum_panel() -> void:
	sum_panel = ui_layer.find_child("SumPanel", true, false) as Control
	if sum_panel:
		return
	var sum_panel_scene := load("res://Game/UI/SumPanel/SumPanel.tscn")
	if not sum_panel_scene:
		return
	sum_panel = sum_panel_scene.instantiate() as Control
	if not sum_panel:
		return
	sum_panel.name = "SumPanel"
	ui_layer.add_child(sum_panel)


# ==================== HUD 按钮处理 ====================
func _on_hud_back_pressed() -> void:
	# 优先级0：关闭已注册的自定义面板
	for i in range(open_panels.size() - 1, -1, -1):
		var panel = open_panels[i]
		if is_instance_valid(panel) and panel.visible:
			panel.hide()
			open_panels.remove_at(i)
			return

	# 优先级1：关闭物品详情
	if item_detail and item_detail.visible:
		item_detail.close_detail()
		return
	# 优先级2：关闭当前打开的近景
	for area in zoom_views_root.get_children():
		for child in area.get_children():
			if child.has_method("hide_view") and child.visible:
				child.hide_view()
				return


func _on_hud_book_pressed() -> void:
	# 打开记录册
	if record_panel and record_panel.has_method("open_panel"):
		record_panel.open_panel()


func _on_hud_items_pressed() -> void:
	if sum_panel and sum_panel.has_method("open_panel"):
		sum_panel.open_panel()
		register_panel_open(sum_panel)


func _on_item_recorded(item_id: String, entry_title: String, entry_description: String, entry_title_2: String, entry_description_2: String) -> void:
	if record_panel and record_panel.has_method("add_or_update_entry"):
		record_panel.call("add_or_update_entry", item_id, entry_title, entry_description)
		if not entry_title_2.strip_edges().is_empty() or not entry_description_2.strip_edges().is_empty():
			record_panel.call("add_or_update_entry", item_id + "_b", entry_title_2, entry_description_2)
	if sum_panel and sum_panel.has_method("add_record_entry"):
		sum_panel.call("add_record_entry", item_id, entry_title, entry_description)
		if not entry_title_2.strip_edges().is_empty() or not entry_description_2.strip_edges().is_empty():
			sum_panel.call("add_record_entry", item_id + "_b", entry_title_2, entry_description_2)
