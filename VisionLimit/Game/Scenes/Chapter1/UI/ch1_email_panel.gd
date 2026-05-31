extends Control

@onready var confirm_btn: Button = $ConfirmButton


func _ready() -> void:
	confirm_btn.pressed.connect(_on_confirm_pressed)
	hide()


func _on_confirm_pressed() -> void:
	hide()
