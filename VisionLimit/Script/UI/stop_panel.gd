extends CanvasLayer

const RECORD_PANEL_SCENE := preload("res://Game/UI/RecordPanel/RecordPanel.tscn")

@onready var record_button: TextureButton = $button/UI3/TextureButton

@onready var back_button = $BackButton


func _ready() -> void:
	if record_button:
		record_button.pressed.connect(_on_record_button_pressed)
	if back_button and back_button.has_node("TextureButton"):
		back_button.get_node("TextureButton").pressed.connect(hide)


# ==================== 面板打开/关闭接口 ====================
func open_panel() -> void:
	"""打开菜单面板"""
	show()


func _on_record_button_pressed() -> void:
	var record_panel := _find_record_panel()
	if not record_panel:
		record_panel = _create_record_panel()
	if record_panel and record_panel.has_method("open_panel"):
		record_panel.call("open_panel")


# ==================== Back 按钮处理 ====================
func close_panel() -> void:
	"""使用 hide() 方法关闭菜单面板"""
	hide()


func _find_record_panel() -> Control:
	var root := get_tree().current_scene
	if not root:
		return null
	return root.find_child("RecordPanel", true, false) as Control


func _create_record_panel() -> Control:
	var root := get_tree().current_scene
	if not root:
		return null
	var panel := RECORD_PANEL_SCENE.instantiate() as Control
	if not panel:
		return null
	panel.name = "RecordPanel"
	var ui_layer := root.find_child("UILayer", true, false)
	if ui_layer:
		ui_layer.add_child(panel)
	else:
		root.add_child(panel)
	return panel
