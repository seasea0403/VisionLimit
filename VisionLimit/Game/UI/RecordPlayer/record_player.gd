extends Control

# 音频播放完毕、玩家按下 Back 后发出
signal playback_done

# ==================== 节点引用 ====================
@onready var bars_container: Control = $Panel/BarsContainer
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var back_button: TextureButton = $Panel/back/TextureButton

# ==================== 常量 ====================
const BAR_COUNT    := 12
const BAR_WIDTH    := 22.0
const BAR_GAP      := 10.0
const CONT_HEIGHT  := 120.0   # BarsContainer 高度，与 tscn 中保持一致
const BAR_MAX_H    := 110.0
const BAR_MIN_H    := 6.0

# 录音字幕（time = 距播放开始的秒数）
const SUBTITLES: Array = [
	{"time":  0.0, "text": "[——静噪——]"},
	{"time":  2.5, "text": "[——断——] ——C-03海域，汞浓度从二月份就开始——[——断——]"},
	{"time":  5.5, "text": "[——断——] ——他们一直知道我在调查什么——[——断——]"},
	{"time":  8.5, "text": "[——静噪，持续约2秒——]"},
	{"time": 11.5, "text": "——那些数据，我需要找地方存储——[——断——]"},
	{"time": 15.0, "text": "——不能留在这里了。他们迟早会来——[——断——]"},
	{"time": 19.0, "text": "——我没有地方可以放它，没有任何人可以托付——[——停顿——]"},
	{"time": 23.5, "text": "——所以我把它藏进——[切断]"},
]

# ==================== 状态变量 ====================
var _bars: Array = []
var _phase_offsets: Array = []
var _is_playing := false
var _audio_player: AudioStreamPlayer2D = null
var _elapsed := 0.0
var _subtitle_index := 0

# ==================== 初始化 ====================
func _ready() -> void:
	_spawn_bars()
	back_button.hide()
	back_button.pressed.connect(_on_back_pressed)
	hide()


func _spawn_bars() -> void:
	for i in BAR_COUNT:
		var bar := ColorRect.new()
		var h := BAR_MIN_H
		bar.size     = Vector2(BAR_WIDTH, h)
		bar.position = Vector2(i * (BAR_WIDTH + BAR_GAP), CONT_HEIGHT - h)
		bar.color    = Color(0.35, 0.85, 0.55)
		bars_container.add_child(bar)
		_bars.append(bar)
		_phase_offsets.append(randf() * TAU)

# ==================== 公开接口 ====================
## chapter2.gd 调用此方法开始播放，传入场景中的 RecordAudio 节点
func start_playback(audio_player: AudioStreamPlayer2D) -> void:
	_audio_player = audio_player
	_is_playing    = true
	_elapsed       = 0.0
	_subtitle_index = 0
	subtitle_label.text = ""
	back_button.hide()
	show()
	if not _audio_player.finished.is_connected(_on_audio_finished):
		_audio_player.finished.connect(_on_audio_finished, CONNECT_ONE_SHOT)
	_audio_player.play()

# ==================== 每帧更新 ====================
func _process(delta: float) -> void:
	if not _is_playing:
		return

	# 柱形条动画（正弦波，每根相位不同）
	var t := Time.get_ticks_msec() * 0.003
	for i in _bars.size():
		var h: float = BAR_MIN_H + (BAR_MAX_H - BAR_MIN_H) * (0.5 + 0.5 * sin(t + _phase_offsets[i]))
		_bars[i].size     = Vector2(BAR_WIDTH, h)
		_bars[i].position = Vector2(i * (BAR_WIDTH + BAR_GAP), CONT_HEIGHT - h)

	# 字幕逐行推进
	_elapsed += delta
	if _subtitle_index < SUBTITLES.size():
		if _elapsed >= float(SUBTITLES[_subtitle_index]["time"]):
			subtitle_label.text = SUBTITLES[_subtitle_index]["text"]
			_subtitle_index += 1

# ==================== 内部回调 ====================
func _on_audio_finished() -> void:
	_is_playing = false
	back_button.show()


func _on_back_pressed() -> void:
	_is_playing = false
	if _audio_player and _audio_player.playing:
		_audio_player.stop()
	hide()
	playback_done.emit()
