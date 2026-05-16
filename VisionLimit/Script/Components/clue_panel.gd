class_name CluePanel

extends PanelContainer

## 可拖拽的线索碎片面板
## 调用 setup() 完成初始化后加入场景树

@export var clue_id: String = ""
@export var clue_text: String = ""
@export var reusable: bool = false   # true = 使用后归还线索池（可复用线索）
@export var panel_size: Vector2 = Vector2(160, 80)

@onready var label: Label = $Label


func _ready() -> void:
	custom_minimum_size = panel_size
	if label:
		label.text = clue_text


func setup(id: String, text: String, is_reusable: bool = false) -> void:
	clue_id = id
	clue_text = text
	reusable = is_reusable
	custom_minimum_size = panel_size
	if label:
		label.text = text


## Godot 内置拖拽协议：开始拖拽时调用
func _get_drag_data(_at_position: Vector2) -> Variant:
	# 直接使用当前面板作为拖拽来源，不额外生成小预览卡片
	var preview: Control = duplicate()
	preview.custom_minimum_size = custom_minimum_size
	preview.size = size
	if preview.has_node("Label"):
		var preview_label: Label = preview.get_node("Label")
		preview_label.text = clue_text
	preview.modulate = Color(1, 1, 1, 0.85)
	set_drag_preview(preview)
	return {"clue_id": clue_id, "clue_text": clue_text, "panel": self}


## 错误闪烁效果（卡槽报错时由外部调用）
func flash_error() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.12)
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	tween.tween_property(self, "modulate", Color.RED, 0.12)
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
