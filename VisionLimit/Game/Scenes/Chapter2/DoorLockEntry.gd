extends Node2D

## 玩家点击可点击区域时发出
signal area_clicked

@onready var _click_area: Area2D = $ClickArea


func _ready() -> void:
	_click_area.input_event.connect(_on_click_area_input_event)


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		area_clicked.emit()
