extends CanvasLayer

# 由 DialogueManager 监听，用于推进对话（避免循环依赖）
signal advance_requested(next_id: String, record_key: String, record_value: String)

@onready var speaker_name: Label = $Background/SpeakerName
@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var continue_button: Button = $ContinueButton
@onready var choices_container: VBoxContainer = $Background/ChoicesContainer
@onready var portrait_rect: TextureRect = $PortraitRect
@onready var portrait_rect2: TextureRect = $PortraitRect2
@onready var portrait_head: TextureRect = $PortraitHead
@onready var background: TextureRect = $Background

const CHOICE_BUTTON_SCENE := preload("res://Game/UI/DialoguePanel/ChoiceButton.tscn")

var _pending_choices: Array = []
var _current_next_id: String = ""
var _current_record_key: String = ""
var _current_record_value: String = ""


func _ready() -> void:
	# 对话框文字和按钮始终在最顶层
	dialogue_text.z_index = 2
	continue_button.z_index = 2
	# Background 默认 z_index = 0，立绘通过 z_index 控制在其上方或下方
	background.z_index = 0
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.hide()
	choices_container.hide()

func load_node(node_data: Dictionary) -> void:
	speaker_name.text = node_data.get("speaker", "")
	dialogue_text.text = node_data.get("text", "")

	# 大头立绘（portrait_head）：存在时隐藏左右两个立绘
	var head_path: String = node_data.get("portrait_head", "")
	if head_path != "":
		portrait_head.texture = load(head_path)
		portrait_head.show()
		portrait_rect.hide()
		portrait_rect2.hide()
	else:
		portrait_head.hide()

	# 左侧立绘
	var portrait_path: String = node_data.get("portrait", "")
	if portrait_path != "":
		portrait_rect.texture = load(portrait_path)
		portrait_rect.show()
	else:
		portrait_rect.texture = null
		portrait_rect.hide()

	# 右侧立绘（双人布局）
	var portrait_path2: String = node_data.get("portrait_right", "")
	if portrait_path2 != "":
		portrait_rect2.texture = load(portrait_path2)
		portrait_rect2.show()
	else:
		portrait_rect2.hide()

	# 层级控制：active_side 决定哪侧立绘在 Background 上方（z=1），哪侧在下方（z=-1）
	# "left"  → 左上右下  "right" → 右上左下
	# "none"  → 两侧都在下方  ""      → 两侧都在上方（旧行为）
	const DIM := Color(0.4, 0.4, 0.4, 1.0)
	const BRIGHT := Color(1.0, 1.0, 1.0, 1.0)
	var active_side: String = node_data.get("active_side", "")
	match active_side:
		"left":
			portrait_rect.z_index = 1
			portrait_rect2.z_index = -1
			portrait_rect.modulate = BRIGHT
			portrait_rect2.modulate = DIM
			dialogue_text.position.x = 400
		"right":
			portrait_rect.z_index = -1
			portrait_rect2.z_index = 1
			portrait_rect.modulate = DIM
			portrait_rect2.modulate = BRIGHT
			dialogue_text.position.x = 270
		"none":
			portrait_rect.z_index = -1
			portrait_rect2.z_index = -1
			portrait_rect.modulate = DIM
			portrait_rect2.modulate = DIM
			dialogue_text.position.x = 270
		_:
			portrait_rect.z_index = 1
			portrait_rect2.z_index = 1
			portrait_rect.modulate = BRIGHT
			portrait_rect2.modulate = BRIGHT
			dialogue_text.position.x = 270

	continue_button.hide()
	_clear_choices()

	_pending_choices = node_data.get("choices", [])
	_current_next_id = node_data.get("next", "")
	_current_record_key = ""
	_current_record_value = ""
	_show_controls()


# ==================== 控件显示 ====================
const BUTTON_GAP: float = 100

func _show_controls() -> void:
	if _pending_choices.size() > 0:
		var y_offset: float = 0.0
		for choice in _pending_choices:
			var btn = CHOICE_BUTTON_SCENE.instantiate()
			btn.setup(choice["text"])

			var condition_met: bool = true
			if choice.has("condition"):
				condition_met = GameStateManager.has_clue(choice["condition"])

			if condition_met:
				var next_id: String = choice.get("next", "")
				var record_key: String = choice.get("record_key", "")
				var record_value: String = choice.get("record_value", "")
				if choice.has("response"):
					var resp_text: String = choice["response"]
					var resp_portrait: String = choice.get("response_portrait", "res://Art/Character/沈意常规.png")
					btn.pressed.connect(func(): _show_response(resp_text, resp_portrait, next_id, record_key, record_value))
				else:
					btn.pressed.connect(func(): advance_requested.emit(next_id, record_key, record_value))
			else:
				btn.disabled = true
				btn.modulate = Color(0.5, 0.5, 0.5, 1.0)

			choices_container.add_child(btn)
			btn.position = Vector2(0.0, y_offset)
			y_offset += btn.button_height + BUTTON_GAP

		choices_container.show()
	else:
		continue_button.show()


func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()
	choices_container.hide()


func _show_response(response_text: String, portrait_path: String, next_id: String, record_key: String, record_value: String) -> void:
	_clear_choices()
	speaker_name.text = "沈意"
	dialogue_text.text = response_text
	if portrait_path != "":
		portrait_rect.texture = load(portrait_path)
		portrait_rect.show()
	else:
		portrait_rect.texture = null
		portrait_rect.hide()
	# 选项回应时：沈意在左说话，左上右下
	dialogue_text.position.x = 400
	if portrait_rect2.visible:
		portrait_rect.z_index = 1
		portrait_rect2.z_index = -1
		portrait_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
		portrait_rect2.modulate = Color(0.4, 0.4, 0.4, 1.0)
	_current_next_id = next_id
	_current_record_key = record_key
	_current_record_value = record_value
	continue_button.show()


func _on_continue_pressed() -> void:
	advance_requested.emit(_current_next_id, _current_record_key, _current_record_value)
	_current_record_key = ""
	_current_record_value = ""
