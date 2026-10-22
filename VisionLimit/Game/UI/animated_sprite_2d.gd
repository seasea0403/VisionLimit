extends AnimatedSprite2D

## 在 Inspector 中指定实际的“开始游戏”按钮。
@export var hover_button: BaseButton

func _ready() -> void:
	_stop_and_reset()
	if hover_button:
		hover_button.mouse_entered.connect(_on_hover_started)
		hover_button.mouse_exited.connect(_stop_and_reset)


func _on_hover_started() -> void:
	if is_visible_in_tree() and not hover_button.disabled:
		play(&"fish")


func _stop_and_reset() -> void:
	stop()
	frame = 0


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_stop_and_reset()
