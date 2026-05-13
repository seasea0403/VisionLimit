extends Control

var entries: Dictionary = {}
var selected_entry_key: String = "default_memory_sea"

@onready var panel: Panel = $Panel
@onready var entry_list: VBoxContainer = $Panel/Layout/LeftPage/Scroll/EntryList
@onready var detail_label: Label = $Panel/Layout/RightPage/DetailDescription
@onready var back_button = $Panel/BackButton


func _ready() -> void:
	if back_button and back_button.has_node("TextureButton"):
		back_button.get_node("TextureButton").pressed.connect(hide)
	_seed_default_entries()
	hide()


func _seed_default_entries() -> void:
	if entries.has("default_memory_sea"):
		return
	entries["default_memory_sea"] = {
		"title": "记忆海",
		"description": "记忆海中的记忆有着不退化、随取随用等区别于真实记忆的特点，具体而言，真实记忆由真实经历产生，通过神经突触的动态连接网络存储。由海芯写入记忆海中的固化记忆，将以高密度固化编码形式存储。它不依赖突触强化维持，且不会退化和变形。\n这两种记忆在主观体验上感觉一样。无法靠内省判断某段记忆是真实经历还是写进去的。但在神经结构层面，两者有明确的格式差异，受过训练的人可以识别。"
	}
	_rebuild_entry_list()


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
	for child in entry_list.get_children():
		child.queue_free()

	var keys := entries.keys()
	keys.sort()
	for key in keys:
		var data: Dictionary = entries[key]
		var button := Button.new()
		var title: String = data.get("title", key)
		button.text = title if key != selected_entry_key else title + "\n______"
		button.custom_minimum_size = Vector2(0, 52)
		button.flat = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		button.add_theme_font_size_override("font_size", 26)
		button.pressed.connect(_on_entry_pressed.bind(key))
		entry_list.add_child(button)


func _on_entry_pressed(key: String) -> void:
	selected_entry_key = key
	_rebuild_entry_list()
	_open_entry(key)


func _open_entry(key: String) -> void:
	if not entries.has(key):
		return
	var data: Dictionary = entries[key]
	var description: String = data.get("description", "")
	detail_label.text = description
