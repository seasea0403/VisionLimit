extends Node2D

@onready var close_button: Button = $CloseButton


# ==================== 初始化 ====================
func _ready() -> void:
	if close_button:
		close_button.pressed.connect(hide_view)


# ==================== 对外接口 ====================
func show_view() -> void:
	show()


func hide_view() -> void:
	hide()
