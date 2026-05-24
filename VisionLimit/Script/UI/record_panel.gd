@tool
extends Control

var entries: Dictionary = {}
var selected_entry_key: String = "default_memory_sea"

var _entry_button_min_height: float = 52.0
var _entry_button_font_size: int = 26
var _entry_button_font: Font
var _entry_button_selected_font: Font
var _entry_button_font_color: Color = Color(0, 0, 0, 1)
var _entry_button_selected_font_color: Color = Color(0.35, 0.16, 0.08, 1)
var _editor_preview_enabled: bool = true
var _editor_preview_titles: PackedStringArray = ["记忆海", "苍屿症", "郑和平"]
var _editor_preview_description: String = "在编辑器中预览词条按钮的字体、字号和选中颜色。运行游戏后这里会显示真实词条内容。"
var _editor_preview_selected_index: int = 0

@export_group("Entry Button Style")
@export var entry_button_min_height: float = 52.0:
	set(value):
		_entry_button_min_height = value
		_queue_preview_refresh()
	get:
		return _entry_button_min_height
@export var entry_button_font_size: int = 26:
	set(value):
		_entry_button_font_size = value
		_queue_preview_refresh()
	get:
		return _entry_button_font_size
@export var entry_button_font: Font:
	set(value):
		_entry_button_font = value
		_queue_preview_refresh()
	get:
		return _entry_button_font
@export var entry_button_selected_font: Font:
	set(value):
		_entry_button_selected_font = value
		_queue_preview_refresh()
	get:
		return _entry_button_selected_font
@export var entry_button_font_color: Color = Color(0, 0, 0, 1):
	set(value):
		_entry_button_font_color = value
		_queue_preview_refresh()
	get:
		return _entry_button_font_color
@export var entry_button_selected_font_color: Color = Color(0.35, 0.16, 0.08, 1):
	set(value):
		_entry_button_selected_font_color = value
		_queue_preview_refresh()
	get:
		return _entry_button_selected_font_color

@export_group("Editor Preview")
@export var editor_preview_enabled: bool = true:
	set(value):
		_editor_preview_enabled = value
		_queue_preview_refresh()
	get:
		return _editor_preview_enabled
@export var editor_preview_titles: PackedStringArray = ["记忆海", "苍屿症", "郑和平"]:
	set(value):
		_editor_preview_titles = value
		_queue_preview_refresh()
	get:
		return _editor_preview_titles
@export_multiline var editor_preview_description: String = "在编辑器中预览词条按钮的字体、字号和选中颜色。运行游戏后这里会显示真实词条内容。":
	set(value):
		_editor_preview_description = value
		_queue_preview_refresh()
	get:
		return _editor_preview_description
@export var editor_preview_selected_index: int = 0:
	set(value):
		_editor_preview_selected_index = value
		_queue_preview_refresh()
	get:
		return _editor_preview_selected_index

@onready var panel: Panel = $Panel
@onready var entry_list: VBoxContainer = $Panel/Layout/LeftPage/Scroll/EntryList
@onready var detail_label: Label = $Panel/Layout/RightPage/DetailDescription
@onready var back_button = $Panel/BackButton/TextureButton


func _ready() -> void:
	if Engine.is_editor_hint():
		_queue_preview_refresh()
		return

	# back_button 已经是 TextureButton 本身，直接连接 pressed 信号
	if back_button:
		back_button.pressed.connect(close_panel)
	_seed_default_entries()
	_load_persistent_entries()
	hide()


func _seed_default_entries() -> void:
	if entries.has("default_memory_sea"):
		return
	entries["default_memory_sea"] = {
		"title": "记忆海",
		"description": "记忆海中的记忆有着不退化、随取随用等区别于真实记忆的特点，具体而言，真实记忆由真实经历产生，通过神经突触的动态连接网络存储。由海芯写入记忆海中的固化记忆，将以高密度固化编码形式存储。它不依赖突触强化维持，且不会退化和变形。\n这两种记忆在主观体验上感觉一样。无法靠内省判断某段记忆是真实经历还是写进去的。但在神经结构层面，两者有明确的格式差异，受过训练的人可以识别。"
	}
	_rebuild_entry_list()


func _load_persistent_entries() -> void:
	"""从 GameStateManager 读取所有已收集词条，恢复到本面板（跨章节持久化）"""
	if not Engine.has_singleton("GameStateManager") and not _has_gsm():
		_rebuild_entry_list()
		return
	var gsm := _get_gsm()
	if gsm == null or not gsm.has_method("get_record_entries"):
		_rebuild_entry_list()
		return
	var saved: Dictionary = gsm.call("get_record_entries")
	for key in saved.keys():
		var data: Dictionary = saved[key]
		entries[key] = {
			"title": data.get("title", key),
			"description": data.get("description", "")
		}
	_rebuild_entry_list()


func _get_gsm() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	var root := tree.root
	if root == null:
		return null
	return root.get_node_or_null("GameStateManager")


func _has_gsm() -> bool:
	return _get_gsm() != null


func add_or_update_entry(item_id: String, entry_title: String, entry_description: String) -> void:
	var key := item_id.strip_edges()
	if key.is_empty():
		key = entry_title.strip_edges()
	if key.is_empty():
		return

	var title := entry_title.strip_edges()
	if title.is_empty():
		title = key

	entries[key] = {
		"title": title,
		"description": entry_description.strip_edges()
	}

	# 同步写入全局，保证切换场景后下个章节的 RecordPanel 仍能读到
	var gsm := _get_gsm()
	if gsm and gsm.has_method("add_record_entry"):
		gsm.call("add_record_entry", key, title, entry_description)

	selected_entry_key = key
	_rebuild_entry_list()
	_open_entry(key)


func open_panel() -> void:
	show()
	move_to_front()


func close_panel() -> void:
	"""关闭记录册面板"""
	hide()


func toggle_panel() -> void:
	visible = not visible


func _rebuild_entry_list() -> void:
	if not is_instance_valid(entry_list):
		return

	for child in entry_list.get_children():
		child.queue_free()

	var source_entries := _get_display_entries()
	var keys := source_entries.keys()
	keys.sort()
	for key in keys:
		var data: Dictionary = source_entries[key]
		var button := Button.new()
		var title: String = data.get("title", key)
		var is_selected: bool = key == selected_entry_key
		var button_color := _entry_button_selected_font_color if is_selected else _entry_button_font_color
		button.text = title
		button.custom_minimum_size = Vector2(0, _entry_button_min_height)
		button.flat = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_color_override("font_color", button_color)
		button.add_theme_color_override("font_hover_color", button_color)
		button.add_theme_color_override("font_pressed_color", button_color)
		button.add_theme_color_override("font_focus_color", button_color)
		button.add_theme_font_size_override("font_size", _entry_button_font_size)

		var font_override: Font = _entry_button_selected_font if is_selected and _entry_button_selected_font else _entry_button_font
		if font_override:
			button.add_theme_font_override("font", font_override)

		if not Engine.is_editor_hint():
			button.pressed.connect(_on_entry_pressed.bind(key))
		entry_list.add_child(button)


func _on_entry_pressed(key: String) -> void:
	selected_entry_key = key
	_rebuild_entry_list()
	_open_entry(key)


func _open_entry(key: String) -> void:
	var source_entries := _get_display_entries()
	if not source_entries.has(key):
		return
	var data: Dictionary = source_entries[key]
	var description: String = data.get("description", "")
	detail_label.text = description


func _get_display_entries() -> Dictionary:
	if Engine.is_editor_hint() and _editor_preview_enabled:
		return _build_editor_preview_entries()
	return entries


func _build_editor_preview_entries() -> Dictionary:
	var preview_entries: Dictionary = {}
	for index in range(_editor_preview_titles.size()):
		var title := _editor_preview_titles[index].strip_edges()
		if title.is_empty():
			continue
		preview_entries["preview_%s" % index] = {
			"title": title,
			"description": _editor_preview_description
		}

	if preview_entries.is_empty():
		preview_entries["preview_0"] = {
			"title": "预览词条",
			"description": _editor_preview_description
		}

	var preview_keys := preview_entries.keys()
	preview_keys.sort()
	var clamped_index := clampi(_editor_preview_selected_index, 0, max(preview_keys.size() - 1, 0))
	selected_entry_key = preview_keys[clamped_index]
	return preview_entries


func _queue_preview_refresh() -> void:
	if not is_node_ready():
		return
		
	call_deferred("_refresh_preview")


func _refresh_preview() -> void:
	if not is_node_ready():
		return
	_rebuild_entry_list()
	_open_entry(selected_entry_key)
