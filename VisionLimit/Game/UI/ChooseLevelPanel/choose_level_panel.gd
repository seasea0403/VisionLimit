extends Control

const DRAG_THRESHOLD: float = 10.0

@onready var _scroll: ScrollContainer = $ScrollContainer
@onready var _hbox: HBoxContainer = $ScrollContainer/HBoxContainer

var _pointer_down: bool = false
var _dragging: bool = false
var _press_position: Vector2
var _press_scroll: int
var _pressed_button: BaseButton


func _ready() -> void:
	_refresh_level_states()
	for level in _hbox.get_children():
		var button := level.find_child("TextureButton", true, false) as BaseButton
		if button:
			button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _scroll.get_global_rect().has_point(event.position):
				return
			_pointer_down = true
			_dragging = false
			_press_position = event.position
			_press_scroll = _scroll.scroll_horizontal
			var target: Node = get_viewport().gui_get_hovered_control()
			while target and not target is BaseButton:
				target = target.get_parent()
			_pressed_button = target as BaseButton
		else:
			if _dragging:
				get_viewport().set_input_as_handled()
			_reset_drag()
	elif event is InputEventMouseMotion and _pointer_down:
		var distance: float = event.position.x - _press_position.x
		if not _dragging and absf(distance) >= DRAG_THRESHOLD:
			_dragging = true
			_cancel_button_press()
		if _dragging:
			_scroll.scroll_horizontal = _press_scroll - roundi(distance)
			get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_VISIBILITY_CHANGED:
		_reset_drag()


func _cancel_button_press() -> void:
	if is_instance_valid(_pressed_button) and not _pressed_button.disabled:
		# 清掉原按钮的按住状态，避免拖动松手时进入关卡或残留按下颜色。
		_pressed_button.disabled = true
		_pressed_button.disabled = false
		_pressed_button.button_up.emit()
	_pressed_button = null


func _reset_drag() -> void:
	if _dragging:
		_cancel_button_press()
	_pointer_down = false
	_dragging = false
	_pressed_button = null


# 刷新所有关卡按钮的解锁状态
func _refresh_level_states() -> void:
	for level in _hbox.get_children():
		var btn := level.find_child("TextureButton", true, false) as TextureButton
		if btn and btn.has_method("update_button_state"):
			btn.update_button_state()
