extends Control

@onready var back_button: TextureButton = $back/TextureButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		var hud := _get_hud_panel()
		if hud:
			if visible:
				hud.hide()
			else:
				hud.show()


func _on_back_pressed() -> void:
	hide()


func _get_hud_panel() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().get_root().find_child("HudPanel", true, false)
