extends Control

signal intro_finished

@export var autoplay: bool = true
@export var manage_hud: bool = true
@export var end_action_text: String = "点击结束广告"
@export var page_images: Array[Texture2D] = []
@export_multiline var page_texts: Array[String] = [
	"读过的，能否不再遗忘？\n让每一次求知，都成为随时可以取用的积累。",
	"需要的，能否随时想起？\n从课堂到诊室，从法庭到工程现场，让信息在需要时触手可及。",
	"珍贵的，能否留得更久？\n一张照片，一段影像。将值得珍藏的片段保存，留待未来再次打开。",
	"二十一世纪中叶，记忆数字化走向商用。\n海芯——一枚植入颅内的微型神经芯片，为记忆开辟新的空间。",
	"海芯在海马体旁侧建立可读写的神经扩展区域，俗称“记忆海”。\n外部数据写入其中，便可随时提取，永不退化。\n截至目前，全球发达城市的海芯持有率已超过70%。",
]
@export_range(0.1, 3.0, 0.05) var image_fade_duration: float = 0.55
@export_range(0.1, 3.0, 0.05) var text_fade_duration: float = 0.8
@export_range(0.1, 3.0, 0.05) var exit_fade_duration: float = 0.9

@onready var page: Control = $Panel
@onready var picture: TextureRect = $Panel/Picture
@onready var label: RichTextLabel = $Panel/Label
@onready var hint: Label = $Panel/Hint
@onready var button: Button = $Button

var _page_index: int = 0
var _transitioning: bool = false
var _text_ready: bool = false
var _closing: bool = false
var _text_tween: Tween
var _hud: CanvasItem


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	if autoplay:
		play()
	else:
		hide()


func play() -> void:
	_page_index = 0
	_closing = false
	modulate.a = 1.0
	show()
	_hud = get_parent().get_node_or_null("HudPanel") as CanvasItem
	if manage_hud and _hud:
		_hud.hide()
	_show_page()


func _show_page() -> void:
	_transitioning = true
	_text_ready = false
	page.modulate.a = 0.0
	label.modulate.a = 0.0
	hint.modulate.a = 0.0
	picture.texture = page_images[_page_index] if _page_index < page_images.size() else null
	label.text = page_texts[_page_index]
	var action := end_action_text if _page_index == page_texts.size() - 1 else "点击继续"
	hint.text = "%s  ·  %d / %d" % [action, _page_index + 1, page_texts.size()]
	var image_tween := create_tween()
	image_tween.tween_property(page, "modulate:a", 1.0, image_fade_duration)
	await image_tween.finished
	_transitioning = false
	_text_tween = create_tween().set_parallel(true)
	_text_tween.tween_property(label, "modulate:a", 1.0, text_fade_duration)
	_text_tween.tween_property(hint, "modulate:a", 1.0, text_fade_duration)
	_text_tween.finished.connect(_on_text_revealed)


func _on_text_revealed() -> void:
	_text_ready = true


func _on_button_pressed() -> void:
	if _transitioning or _closing:
		return
	# 阅读时可以立即显全文；过场期间拦截连点，避免跳页和重复退出。
	if not _text_ready:
		if _text_tween:
			_text_tween.kill()
		label.modulate.a = 1.0
		hint.modulate.a = 1.0
		_text_ready = true
		return
	if _page_index == page_texts.size() - 1:
		_finish_intro()
		return
	_transitioning = true
	var fade_out := create_tween()
	fade_out.tween_property(page, "modulate:a", 0.0, 0.2)
	await fade_out.finished
	_page_index += 1
	_show_page()


func _finish_intro() -> void:
	_closing = true
	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, exit_fade_duration)
	await fade_out.finished
	hide()
	if manage_hud and is_instance_valid(_hud):
		_hud.show()
	intro_finished.emit()
