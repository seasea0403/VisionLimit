extends Control

@onready var _hbox: HBoxContainer = $ScrollContainer/HBoxContainer


func _ready() -> void:
	_refresh_level_states()


# 刷新所有关卡按钮的解锁状态
func _refresh_level_states() -> void:
	for level in _hbox.get_children():
		var btn := level.find_child("TextureButton", true, false) as TextureButton
		if btn and btn.has_method("update_button_state"):
			btn.update_button_state()
