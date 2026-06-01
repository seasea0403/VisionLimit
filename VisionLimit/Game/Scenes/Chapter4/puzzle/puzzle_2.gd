extends Control

# ==================== 配置参数 ====================
@export var correct_password: String = "1234"
@export var max_digits: int = 4
@export var click_sound: AudioStream

# ==================== 信号 ====================
signal password_correct()
signal password_wrong()

# ==================== 子节点引用 ====================
@onready var display_label = $Label
@onready var status_label  = $Label2

@onready var _digit_buttons: Array = [
	$button/Button,  $button/Button2, $button/Button3,
	$button/Button4, $button/Button5, $button/Button6,
	$button/Button7, $button/Button8, $button/Button9,
	$button/Button10,
]
# 按钮对应的数字（1-9，0）
const _BUTTON_DIGITS: Array = ["1","2","3","4","5","6","7","8","9","0"]

@onready var _delete_button = $button/Button11
@onready var _confirm_button = $button/Button12

# ==================== 状态变量 ====================
var current_input: String = ""
var _is_checking: bool = false
var _default_status_text: String = ""

# ==================== 音效 ====================
var _audio_player: AudioStreamPlayer

# ==================== 初始化 ====================
func _ready() -> void:
	_default_status_text = status_label.text if status_label else ""
	_update_display()

	if click_sound:
		_audio_player = AudioStreamPlayer.new()
		_audio_player.stream = click_sound
		add_child(_audio_player)

	# 连接数字按钮
	for i in _digit_buttons.size():
		_digit_buttons[i].pressed.connect(_on_digit_pressed.bind(_BUTTON_DIGITS[i]))

	# 连接 * 删除 和 # 确认
	_delete_button.pressed.connect(_on_delete_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)

# ==================== 公开接口 ====================
func open() -> void:
	current_input = ""
	_is_checking = false
	if status_label:
		status_label.text = _default_status_text
		status_label.modulate = Color.WHITE
	_update_display()
	show()

func close() -> void:
	hide()

# ==================== 按钮回调 ====================
func _on_digit_pressed(digit: String) -> void:
	if _is_checking:
		return
	if current_input.length() >= max_digits:
		return

	if _audio_player:
		_audio_player.play()

	current_input += digit
	_update_display()

	if current_input.length() == max_digits:
		_check_password()

func _on_delete_pressed() -> void:
	if _is_checking:
		return
	if current_input.length() == 0:
		return
	if _audio_player:
		_audio_player.play()
	current_input = current_input.left(current_input.length() - 1)
	_update_display()


func _on_confirm_pressed() -> void:
	if _is_checking:
		return
	if current_input.length() == 0:
		return
	if _audio_player:
		_audio_player.play()
	_check_password()


# ==================== 内部逻辑 ====================
func _check_password() -> void:
	_is_checking = true

	if current_input == correct_password:
		if status_label:
			status_label.modulate = Color(0.2, 0.9, 0.3)
			status_label.text = "✓ 解锁成功"

		password_correct.emit()

		await get_tree().create_timer(0.8).timeout
		close()
	else:
		if status_label:
			status_label.modulate = Color(0.9, 0.2, 0.2)
			status_label.text = "✗ 密码错误"

		password_wrong.emit()
		_shake_display()

		await get_tree().create_timer(0.6).timeout
		current_input = ""
		_is_checking = false
		if status_label:
			status_label.text = _default_status_text
			status_label.modulate = Color.WHITE
		_update_display()

func _update_display() -> void:
	if not display_label:
		return
	var shown := ""
	for i in max_digits:
		if i < current_input.length():
			shown += "●"
		else:
			shown += "_"
		if i < max_digits - 1:
			shown += "  "
	display_label.text = shown

func _shake_display() -> void:
	if not display_label:
		return
	var origin: Vector2 = display_label.position
	for i in 6:
		display_label.position = origin + Vector2(randf_range(-6, 6), 0)
		await get_tree().create_timer(0.05).timeout
	display_label.position = origin
