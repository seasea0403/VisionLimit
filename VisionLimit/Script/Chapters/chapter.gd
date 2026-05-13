extends Node2D

@onready var item_detail = $UILayer/ItemDetail
@onready var zoom_views_root = $ZoomViews
@onready var clickable_areas = $ZoomViews.get_children()
@onready var ui_layer = $UILayer
@onready var hud_back_button = $UILayer/HudPanel/back/TextureButton
@onready var hud_book_button = $UILayer/HudPanel/book/TextureButton

var record_panel: Control
# 记录当前显示的面板，back 按钮根据此值决定关闭谁
var _current_panel: Node = null


func _ready():
	zoom_views_root.show()
	for area in clickable_areas:
		area.show()
		for child in area.get_children():
			if child.has_method("hide_view"):
				child.hide_view()

	item_detail.hide()
	_setup_record_panel()

	if item_detail and item_detail.has_signal("item_recorded"):
		if not item_detail.item_recorded.is_connected(_on_item_recorded):
			item_detail.item_recorded.connect(_on_item_recorded)

	if hud_back_button:
		hud_back_button.pressed.connect(_on_hud_back_pressed)
	else:
		push_warning("chapter.gd: 找不到 HUD back 按钮，路径 $UILayer/HudPanel/back/TextureButton")

	if hud_book_button:
		hud_book_button.pressed.connect(_on_hud_book_pressed)
	else:
		push_warning("chapter.gd: 找不到 HUD book 按钮，路径 $UILayer/HudPanel/book/TextureButton")


# ==================== 面板追踪 ====================
func register_panel_open(panel: Node) -> void:
	"""任意面板显示时调用此方法，让 back 知道关闭谁"""
	_current_panel = panel


# ==================== HUD 按钮处理 ====================
func _on_hud_back_pressed() -> void:
	# 如果有追踪到的面板且仍可见，直接关闭它
	if _current_panel and is_instance_valid(_current_panel) and _current_panel.visible:
		if _current_panel.has_method("close_detail"):
			_current_panel.close_detail()
		elif _current_panel.has_method("hide_view"):
			_current_panel.hide_view()
		elif _current_panel.has_method("close_panel"):
			_current_panel.close_panel()
		else:
			_current_panel.hide()
		_current_panel = null
		return

	# 兜底：逐层查找可见面板
	if item_detail and item_detail.visible:
		item_detail.close_detail()
		return
	for area in zoom_views_root.get_children():
		for child in area.get_children():
			if child.has_method("hide_view") and child.visible:
				child.hide_view()
				return


func _on_hud_book_pressed() -> void:
	if record_panel and record_panel.has_method("open_panel"):
		record_panel.open_panel()
		_current_panel = record_panel


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


func _on_item_recorded(item_id: String, entry_title: String, entry_description: String, entry_title_2: String, entry_description_2: String) -> void:
	if not record_panel:
		return
	if record_panel.has_method("add_or_update_entry"):
		record_panel.call("add_or_update_entry", item_id, entry_title, entry_description)
		if not entry_title_2.strip_edges().is_empty() or not entry_description_2.strip_edges().is_empty():
			record_panel.call("add_or_update_entry", item_id + "_b", entry_title_2, entry_description_2)
