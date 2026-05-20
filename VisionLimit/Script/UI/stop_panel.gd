extends CanvasLayer

const RECORD_PANEL_SCENE := preload("res://Game/UI/RecordPanel/RecordPanel.tscn")
const CHOOSE_LEVEL_PANEL_SCENE := preload("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
const NOTEBOOK_PANEL_SCENE := preload("res://Game/UI/NotebookPanel/NotebookPanel.tscn")
const SETTING_PANEL_SCENE := preload("res://Game/UI/SettingPanel/SettingPanel.tscn")

const MAIN_SCENE_PATH := "res://Game/UI/UIPanel.tscn"

@onready var notebook_button: TextureButton = $button/UI1/TextureButton
@onready var choose_level_button: TextureButton = $button/UI2/TextureButton
@onready var record_button: TextureButton = $button/UI3/TextureButton
@onready var home_button: TextureButton = $button/UI4/TextureButton
@onready var setting_button: TextureButton = $button/UI5/TextureButton
@onready var back_button = $BackButton

# layer=2 的覆盖层，确保子面板渲染在 StopPanel（layer=1）之上
var _overlay_layer: CanvasLayer = null


func _ready() -> void:
	hide()
	_setup_overlay_layer()

	if notebook_button:
		notebook_button.pressed.connect(_on_notebook_button_pressed)
	if choose_level_button:
		choose_level_button.pressed.connect(_on_choose_level_button_pressed)
	if record_button:
		record_button.pressed.connect(_on_record_button_pressed)
	if home_button:
		home_button.pressed.connect(_on_home_button_pressed)
	if setting_button:
		setting_button.pressed.connect(_on_setting_button_pressed)
	if back_button and back_button.has_node("TextureButton"):
		back_button.get_node("TextureButton").pressed.connect(close_panel)


# ==================== 覆盖层初始化 ====================
func _setup_overlay_layer() -> void:
	var root := get_tree().current_scene
	if not root:
		return
	# 避免重复创建
	var existing := root.find_child("StopPanelOverlay", true, false)
	if existing is CanvasLayer:
		_overlay_layer = existing as CanvasLayer
		return
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 2
	_overlay_layer.name = "StopPanelOverlay"
	root.add_child(_overlay_layer)


# ==================== 面板打开/关闭接口 ====================
func open_panel() -> void:
	show()


func close_panel() -> void:
	hide()


# ==================== 按钮处理 ====================
func _on_notebook_button_pressed() -> void:
	_show_overlay_panel("NotebookPanel", NOTEBOOK_PANEL_SCENE)


func _on_record_button_pressed() -> void:
	var panel := _find_panel_in_tree("RecordPanel")
	if not panel:
		panel = RECORD_PANEL_SCENE.instantiate() as Control
		panel.name = "RecordPanel"
	_show_overlay_panel_node(panel)


func _on_choose_level_button_pressed() -> void:
	# 选择关卡：关闭 StopPanel，再显示 ChooseLevelPanel
	close_panel()
	var panel := _find_panel_in_tree("ChooseLevelPanel")
	if not panel:
		panel = _create_panel_in_ui_layer(CHOOSE_LEVEL_PANEL_SCENE, "ChooseLevelPanel")
	if panel:
		panel.show()
		if panel.has_method("open_panel"):
			panel.call("open_panel")


func _on_home_button_pressed() -> void:
	# 返回主界面：直接切换场景（场景切换会自动销毁当前树）
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_setting_button_pressed() -> void:
	_show_overlay_panel("SettingPanel", SETTING_PANEL_SCENE)


# ==================== 辅助：在 overlay 层显示面板 ====================
func _show_overlay_panel(panel_name: String, scene: PackedScene) -> void:
	var panel := _find_panel_in_overlay(panel_name)
	if not panel:
		panel = _find_panel_in_tree(panel_name)
	if not panel:
		panel = scene.instantiate() as Control
		panel.name = panel_name
	_show_overlay_panel_node(panel)


func _show_overlay_panel_node(panel: Control) -> void:
	if not _overlay_layer:
		return
	# 如果面板还没在 overlay 层中，将其移入
	if panel.get_parent() != _overlay_layer:
		if panel.get_parent():
			panel.get_parent().remove_child(panel)
		_overlay_layer.add_child(panel)
	panel.show()
	if panel.has_method("open_panel"):
		panel.call("open_panel")


# ==================== 辅助：查找面板 ====================
func _find_panel_in_overlay(panel_name: String) -> Control:
	if not _overlay_layer:
		return null
	for child in _overlay_layer.get_children():
		if child.name == panel_name and child is Control:
			return child as Control
	return null


func _find_panel_in_tree(panel_name: String) -> Control:
	var root := get_tree().current_scene
	if not root:
		return null
	return root.find_child(panel_name, true, false) as Control


func _create_panel_in_ui_layer(scene: PackedScene, panel_name: String) -> Control:
	var root := get_tree().current_scene
	if not root:
		return null
	var panel := scene.instantiate() as Control
	if not panel:
		return null
	panel.name = panel_name
	var ui_layer := root.find_child("UILayer", true, false)
	if ui_layer:
		ui_layer.add_child(panel)
	else:
		root.add_child(panel)
	return panel
