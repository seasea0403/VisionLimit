extends Control

# ==================== 配置参数 ====================
## 正确密码（在编辑器中设置）
@export var correct_password: String = "1234"

## 最大位数
@export var max_digits: int = 4

## 悬浮音效
@export var hover_sound: AudioStream

## 点击音效
@export var click_sound: AudioStream

# ==================== 子节点引用 ====================
@onready var display_label   = $Label
@onready var status_label    = $Label2
@onready var dark_background = $ColorRect

# ==================== 信号 ====================
## 密码正确时发出
signal password_correct()
## 密码错误时发出
signal password_wrong()

# ==================== 状态变量 ====================
var current_input: String = ""
var _is_checking: bool = false  # 防止动画期间重复输入
var _default_status_text: String = ""  # 保存 status_label 的原始标题文本


# ==================== 初始化 ====================
func _ready() -> void:
	#hide()
	_default_status_text = status_label.text if status_label else ""
	_update_display()
	
	if dark_background:
		dark_background.gui_input.connect(_on_background_clicked)
	
	# 为所有按键连接音效信号
	_connect_button_sounds()


# ==================== 公开接口 ====================
## 打开密码面板
func open() -> void:
	current_input = ""
	_is_checking = false
	if status_label:
		status_label.text = _default_status_text
		status_label.modulate = Color.WHITE
	_update_display()
	show()


## 关闭密码面板
func close() -> void:
	hide()


# ==================== 按钮回调（在编辑器中连接） ====================
## 数字按钮按下 - 把每个数字按钮的 pressed 信号连接到这里
## 在编辑器里：右键数字按钮 → 连接 pressed → 选择 _on_digit_pressed
## 然后在 Bind → 输入对应数字字符串，如 "1", "2" ...
func _on_digit_pressed(digit: String) -> void:
	if _is_checking:
		return
	if current_input.length() >= max_digits:
		return
	
	current_input += digit
	_update_display()
	
	# 达到最大位数时自动验证
	if current_input.length() == max_digits:
		_check_password()


## 删除最后一位按钮
func _on_delete_pressed() -> void:
	if _is_checking:
		return
	if current_input.length() > 0:
		current_input = current_input.left(current_input.length() - 1)
		_update_display()


## 手动确认按钮（可选，也可以靠自动验证）
func _on_confirm_pressed() -> void:
	if _is_checking or current_input.is_empty():
		return
	_check_password()


# ==================== 内部逻辑 ====================
func _check_password() -> void:
	_is_checking = true
	
	if current_input == correct_password:
		# ✅ 密码正确
		if status_label:
			status_label.modulate = Color(0.2, 0.9, 0.3)
			status_label.text = "✓ 解锁成功"
		
		password_correct.emit()
		
		# 短暂显示成功后关闭
		await get_tree().create_timer(0.8).timeout
		close()
	else:
		# ❌ 密码错误
		if status_label:
			status_label.modulate = Color(0.9, 0.2, 0.2)
			status_label.text = "✗ 密码错误"
		
		password_wrong.emit()
		
		# 抖动动画
		_shake_display()
		
		# 0.6秒后清空重新输入
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
	
	# 显示已输入的位数，未输入显示 _
	var shown := ""
	for i in max_digits:
		if i < current_input.length():
			shown += "●"  # 用圆点代替明文数字，更有神秘感
		else:
			shown += "_"
		if i < max_digits - 1:
			shown += "  "
	
	display_label.text = shown


func _shake_display() -> void:
	if not display_label:
		return
	
	var origin_x: float = display_label.position.x
	var tween := create_tween()
	tween.tween_property(display_label, "position:x", origin_x + 12, 0.04)
	tween.tween_property(display_label, "position:x", origin_x - 12, 0.04)
	tween.tween_property(display_label, "position:x", origin_x + 8,  0.04)
	tween.tween_property(display_label, "position:x", origin_x - 8,  0.04)
	tween.tween_property(display_label, "position:x", origin_x,      0.04)


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null:
		return
	if not key_event.pressed:
		return
	
	var keycode: Key = key_event.keycode
	
	# 数字行 1–9, 0
	if keycode >= KEY_1 and keycode <= KEY_9:
		_on_digit_pressed(str(keycode - KEY_0))
	elif keycode == KEY_0:
		_on_digit_pressed("0")
	# 小键盘 0–9
	elif keycode >= KEY_KP_1 and keycode <= KEY_KP_9:
		_on_digit_pressed(str(keycode - KEY_KP_0))
	elif keycode == KEY_KP_0:
		_on_digit_pressed("0")
	# 退格删除
	elif keycode == KEY_BACKSPACE:
		_on_delete_pressed()
	# 回车确认
	elif keycode in [KEY_ENTER, KEY_KP_ENTER]:
		_on_confirm_pressed()
	# Esc 关闭
	elif keycode == KEY_ESCAPE:
		close()
	
	# 面板打开时吞掉所有按键，防止触发游戏其他快捷键
	get_viewport().set_input_as_handled()


func _on_background_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()


# ==================== 音效处理 ====================
func _connect_button_sounds() -> void:
	"""为所有按键连接鼠标和点击音效"""
	var grid_container = $VBoxContainer/GridContainer
	if not grid_container:
		return
	
	# 遍历 GridContainer 中的所有按钮，连接信号
	for button in grid_container.get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_hovered)
			button.pressed.connect(_on_button_clicked)


func _on_button_hovered() -> void:
	"""播放悬浮音效"""
	if hover_sound:
		_play_sound(hover_sound)


func _on_button_clicked() -> void:
	"""播放点击音效"""
	if click_sound:
		_play_sound(click_sound)


func _play_sound(audio_stream: AudioStream) -> void:
	"""播放音效"""
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = audio_stream
	audio_player.volume_db = 0
	audio_player.bus = "SFX"
	add_child(audio_player)
	audio_player.play()
	
	# 播放完毕后删除节点
	await audio_player.finished
	audio_player.queue_free()
