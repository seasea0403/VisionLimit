extends Control

@onready var back_button: TextureButton = $back/TextureButton


func _ready() -> void:
	back_button.pressed.connect(hide)
	hide()
