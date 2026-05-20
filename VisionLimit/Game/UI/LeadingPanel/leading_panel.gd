extends Control

# 每秒显示的字符数
const CHARS_PER_SECOND: float = 10

@onready var label: RichTextLabel = $Panel/Label
@onready var audio_player: AudioStreamPlayer2D = $Panel/Label/AudioStreamPlayer2D
@onready var button:Button = $Panel/Button

var _elapsed: float = 0.0
var _total_chars: int = 0
var _typing_done: bool = false


func _ready() -> void:
	_total_chars = label.get_total_character_count()
	label.visible_characters = 0
	button.hide()

	audio_player.pitch_scale = 0.8
	audio_player.play()


func _process(delta: float) -> void:
	if _typing_done:
		return

	_elapsed += delta
	var chars_to_show := int(_elapsed * CHARS_PER_SECOND)

	if chars_to_show >= _total_chars:
		label.visible_characters = -1
		_typing_done = true
		audio_player.stop()
		button.show()
	else:
		label.visible_characters = chars_to_show
