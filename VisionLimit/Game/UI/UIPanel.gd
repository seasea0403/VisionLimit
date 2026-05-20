extends Control

@onready var main_panel: Control = $MainPanel
@onready var choose_level_panel: Control = $ChooseLevelPanel
@onready var setting_panel: Control = $SettingPanel
@onready var start_button: TextureButton = $MainPanel/setting/TextureButton
@onready var setting_button: TextureButton = $MainPanel/start/TextureButton


func _ready() -> void:
	if start_button and not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)
	if setting_button and not setting_button.pressed.is_connected(_on_setting_pressed):
		setting_button.pressed.connect(_on_setting_pressed)

	if choose_level_panel:
		choose_level_panel.hide()
	if setting_panel:
		setting_panel.hide()


func _on_start_pressed() -> void:
	if choose_level_panel:
		choose_level_panel.show()
		choose_level_panel.move_to_front()
	if setting_panel:
		setting_panel.hide()


func _on_setting_pressed() -> void:
	if setting_panel:
		setting_panel.show()
		setting_panel.move_to_front()
	if choose_level_panel:
		choose_level_panel.hide()
