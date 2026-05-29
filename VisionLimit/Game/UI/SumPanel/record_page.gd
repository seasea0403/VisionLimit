extends Control

# ==================== Inspector 可调配置 ====================
## 词条列表按钮的字号
@export var entry_font_size: int = 28
## 词条列表按钮的字体（留空则使用主题默认）
@export var entry_font: Font
## 选中词条的文字颜色
@export var entry_selected_color: Color = Color(0.35, 0.16, 0.08, 1)
## 未选中词条的文字颜色
@export var entry_normal_color: Color = Color(0.0, 0.0, 0.0, 1)

# ==================== 子节点引用 ====================
@onready var entry_list: VBoxContainer = $EntryListSection/EntryScroll/EntryList
@onready var entry_title: Label = $EntryDetailSection/EntryTitle
@onready var entry_desc: Label = $EntryDetailSection/EntryDescScroll/EntryDesc

# ==================== 状态 ====================
var _records: Dictionary = {}
var _selected_entry_key: String = ""


# ==================== 初始化 ====================
func _ready() -> void:
	_load_persistent_records()


# ==================== 供 SumPanel 调用：切换到本页时刷新 ====================
func on_page_opened() -> void:
	_load_persistent_records()
	_refresh_record_list()


# ==================== 外部写入词条（chapter.gd 等调用）====================
func add_record_entry(key: String, title: String, description: String) -> void:
	var k := key.strip_edges()
	if k.is_empty():
		return
	_records[k] = {"title": title, "description": description}
	# 同步到 GameStateManager 实现跨场景持久化
	GameStateManager.add_record_entry(k, title, description)
	if visible:
		_refresh_record_list()


# ==================== 加载持久化词条 ====================
func _load_persistent_records() -> void:
	var gsm: Node = get_node_or_null("/root/GameStateManager")
	if gsm == null or not gsm.has_method("get_record_entries"):
		return
	var saved: Dictionary = gsm.call("get_record_entries")
	for k in saved.keys():
		var data: Dictionary = saved[k]
		_records[k] = {
			"title": data.get("title", k),
			"description": data.get("description", "")
		}


# ==================== 刷新左侧词条列表 ====================
func _refresh_record_list() -> void:
	for child in entry_list.get_children():
		child.queue_free()

	var keys: Array = _records.keys()
	keys.sort()
	for k in keys:
		var data: Dictionary = _records[k]
		var btn := Button.new()
		btn.text = data.get("title", k)
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", entry_font_size)
		if entry_font:
			btn.add_theme_font_override("font", entry_font)
		if k == _selected_entry_key:
			btn.add_theme_color_override("font_color", entry_selected_color)
		else:
			btn.add_theme_color_override("font_color", entry_normal_color)
		btn.pressed.connect(_on_entry_btn_pressed.bind(k))
		entry_list.add_child(btn)

	if _selected_entry_key in _records:
		_open_entry(_selected_entry_key)
	elif keys.size() > 0:
		_open_entry(keys[0])
	else:
		entry_title.text = ""
		entry_desc.text = ""


func _on_entry_btn_pressed(key: String) -> void:
	_selected_entry_key = key
	_refresh_record_list()
	_open_entry(key)


func _open_entry(key: String) -> void:
	if not _records.has(key):
		return
	_selected_entry_key = key
	var data: Dictionary = _records[key]
	entry_title.text = data.get("title", "")
	entry_desc.text = data.get("description", "")
