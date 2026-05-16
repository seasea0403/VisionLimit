extends PanelContainer

signal card_pressed(item_id: String, side: int)

enum VisualState {
	IDLE,
	SELECTED,
	CORRECT,
	WRONG,
}

@export var item_id: String = ""
@export var item_side: int = 0
@export var item_text: String = ""

@export var idle_tint: Color = Color(1, 1, 1, 1)
@export var selected_tint: Color = Color(0.98, 0.88, 0.50, 1)
@export var correct_tint: Color = Color(0.74, 0.94, 0.78, 1)
@export var wrong_tint: Color = Color(0.98, 0.70, 0.70, 1)

@onready var text_label: Label = $Label

var _state: int = VisualState.IDLE


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if text_label:
		if item_text.strip_edges().is_empty():
			item_text = text_label.text
		else:
			text_label.text = item_text
	_apply_state()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_pressed.emit(item_id, item_side)
		accept_event()


func set_state(state: int) -> void:
	_state = state
	_apply_state()


func _apply_state() -> void:
	match _state:
		VisualState.SELECTED:
			self_modulate = selected_tint
		VisualState.CORRECT:
			self_modulate = correct_tint
		VisualState.WRONG:
			self_modulate = wrong_tint
		_:
			self_modulate = idle_tint