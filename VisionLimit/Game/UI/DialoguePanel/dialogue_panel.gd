extends CanvasLayer

# 由 DialogueManager 监听，用于推进对话（避免循环依赖）
signal advance_requested(next_id: String, record_key: String, record_value: String)

@onready var speaker_name: Label = $Background/SpeakerName
@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var continue_button: Button = $ContinueButton
@onready var choices_container: VBoxContainer = $Background/ChoicesContainer
@onready var portrait_rect: TextureRect = $PortraitRect

const CHOICE_BUTTON_SCENE := preload("res://Game/UI/DialoguePanel/ChoiceButton.tscn")

var _pending_choices: Array = []
var _current_next_id: String = ""
var _current_record_key: String = ""
var _current_record_value: String = ""


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.hide()
	choices_container.hide()

func load_node(node_data: Dictionary) -> void:
	speaker_name.text = node_data.get("speaker", "")
	dialogue_text.text = node_data.get("text", "")

	# 立绘切换
	var portrait_path: String = node_data.get("portrait", "")
	if portrait_path != "":
		portrait_rect.texture = load(portrait_path)
		portrait_rect.show()
	else:
		portrait_rect.texture = null
		portrait_rect.hide()

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
	_current_next_id = next_id
	_current_record_key = record_key
	_current_record_value = record_value
	continue_button.show()


func _on_continue_pressed() -> void:
	advance_requested.emit(_current_next_id, _current_record_key, _current_record_value)
	_current_record_key = ""
	_current_record_value = ""
