extends Control

# 每秒显示的字符数
const CHARS_PER_SECOND: float = 30

@onready var label: RichTextLabel = $Panel/Label
@onready var audio_player: AudioStreamPlayer2D = $Panel/Label/AudioStreamPlayer2D
@onready var button:Button = $Panel/Button

var _elapsed: float = 0.0
var _total_chars: int = 0
var _typing_done: bool = false


func _ready() -> void:
	# HudPanel 在树中排在 LeadingPanel 后面会遮挡它，开始时先隐藏 HudPanel
	var hud := get_parent().get_node_or_null("HudPanel") if get_parent() else null
	if hud:
		hud.hide()

	_total_chars = label.get_total_character_count()
	label.visible_characters = 0
	button.hide()
	button.pressed.connect(_on_button_pressed)

	audio_player.pitch_scale = 0.8
	audio_player.play()


func _on_button_pressed() -> void:
	# 恢复 HudPanel 显示，然后隐藏自身
	var hud := get_parent().get_node_or_null("HudPanel") if get_parent() else null
	if hud:
		hud.show()
	hide()


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
