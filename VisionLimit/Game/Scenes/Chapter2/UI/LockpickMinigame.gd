extends Control

# ==================== 信号 ====================
signal lockpick_success
signal lockpick_failed

# ==================== 可调节参数 ====================
## 按住鼠标时操控条向上的匀速（像素/秒）
@export var up_speed: float = 360.0
## 松开鼠标时操控条向下匀速下落（像素/秒）
@export var down_speed: float = 220.0
## 钥匙上下匀速移动的速度（像素/秒）
@export var key_speed: float = 170.0
## 操控条覆盖钥匙时，进度条每秒增加
@export var fill_rate: float = 0.42
## 未覆盖时，进度条每秒减少
@export var drain_rate: float = 0.28
## 起始进度（0~1），中间值更易上手
@export_range(0.0, 1.0) var initial_progress: float = 0.5
@export_multiline var hint_text: String = "按住鼠标抬升操控条，使其覆盖钥匙"

# ==================== 节点引用 ====================
@onready var _bar_bg: Control        = $BarRoot/BarBg
@onready var _player_bar: Control    = $BarRoot/BarBg/PlayerBar
@onready var _key: Control           = $BarRoot/BarBg/KeyImage
@onready var _success_bar: ProgressBar = $BarRoot/SuccessBar
@onready var _hint_label: Label      = $BarRoot/HintLabel

# ==================== 内部状态 ====================
var _bar_h: float = 0.0
var _player_h: float = 0.0
var _key_h: float = 0.0
var _key_dir: float = 1.0
var _success: float = 0.0
var _active: bool = false
var _holding: bool = false
var _was_overlap: bool = false


func _ready() -> void:
	_hint_label.text = hint_text
	_recalc()
	_active = false


func _recalc() -> void:
	_bar_h = _bar_bg.size.y
	_player_h = _player_bar.size.y
	_key_h = _key.size.y


func start() -> void:
	_recalc()
	_player_bar.position.y = _bar_h - _player_h
	_player_bar.modulate = Color(1, 1, 1, 1)
	_key.position.y = (_bar_h - _key_h) * 0.5
	_key_dir = 1.0
	_success = clampf(initial_progress, 0.0, 1.0)
	_success_bar.value = _success
	_holding = false
	_active = true
	_was_overlap = false


func _process(delta: float) -> void:
	if not _active:
		return

	# —— 玩家操控条：按住向上匀速、松开向下匀速 ——
	var pv: float = -up_speed if _holding else down_speed
	var py: float = clampf(_player_bar.position.y + pv * delta, 0.0, _bar_h - _player_h)
	_player_bar.position.y = py

	# —— 钥匙：匀速上下往复，碰边界反向 ——
	var ky: float = _key.position.y + _key_dir * key_speed * delta
	var ky_max: float = _bar_h - _key_h
	if ky <= 0.0:
		ky = 0.0
		_key_dir = 1.0
	elif ky >= ky_max:
		ky = ky_max
		_key_dir = -1.0
	_key.position.y = ky

	# —— 重叠判定 ——
	var p_top: float = py
	var p_bot: float = py + _player_h
	var k_top: float = ky
	var k_bot: float = ky + _key_h
	var overlap: bool = p_bot > k_top and p_top < k_bot

	if overlap:
		_success = minf(_success + fill_rate * delta, 1.0)
	else:
		_success = maxf(_success - drain_rate * delta, 0.0)
	_success_bar.value = _success

	# —— 视觉反馈：进入/离开重叠时操控条颜色过渡 ——
	if overlap != _was_overlap:
		_was_overlap = overlap
		var c: Color = Color(0.6, 1.0, 0.65, 1.0) if overlap else Color(1, 1, 1, 1)
		var tw: Tween = create_tween()
		tw.tween_property(_player_bar, "modulate", c, 0.15)

	# —— 胜负判定 ——
	if _success >= 1.0:
		_active = false
		lockpick_success.emit()
	elif _success <= 0.0:
		_active = false
		lockpick_failed.emit()


func _gui_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_holding = event.pressed
		accept_event()


func _input(event: InputEvent) -> void:
	# 兜底：即便鼠标移出本控件区域，松开也能被识别
	if not _active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_holding = false
