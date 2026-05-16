class_name ReasoningSlot

extends Panel

## 推理卡槽组件：接受从线索池拖入的碎片面板
## 右键点击可将线索归还线索池

var held_clue_id: String = ""
var held_panel: Control = null   # 当前放入的 CluePanel 引用

signal slot_updated

@onready var content_label: Label = $ContentLabel
@onready var hint_label: Label = $HintLabel


## ──────────────── 拖拽接收 ────────────────

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("clue_id") and held_clue_id == ""


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not (data is Dictionary and data.has("clue_id")):
		return
	held_clue_id = data["clue_id"]
	held_panel = data.get("panel") as Control
	# 隐藏线索池中的原始面板
	if held_panel:
		held_panel.visible = false
	# 在卡槽内显示文字
	content_label.text = data.get("clue_text", held_clue_id)
	content_label.visible = true
	hint_label.visible = false
	slot_updated.emit()


## ──────────────── 清空卡槽（归还线索池）────────────────

func clear_slot() -> void:
	if held_panel:
		held_panel.visible = true   # 将碎片归还线索池
	held_clue_id = ""
	held_panel = null
	content_label.text = ""
	content_label.visible = false
	hint_label.visible = true
	slot_updated.emit()


## 释放卡槽并返回面板引用（由 clue_board 调用后自行决定销毁或归还）
func release_panel() -> Control:
	var panel := held_panel
	held_clue_id = ""
	held_panel = null
	content_label.text = ""
	content_label.visible = false
	hint_label.visible = true
	slot_updated.emit()
	return panel


## ──────────────── 效果 ────────────────

func flash_error() -> void:
	if held_panel:
		held_panel.flash_error()
	var tween := create_tween()
	tween.tween_property(self, "self_modulate", Color(1.0, 0.3, 0.3, 1.0), 0.12)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.12)
	tween.tween_property(self, "self_modulate", Color(1.0, 0.3, 0.3, 1.0), 0.12)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.12)


## 右键点击归还线索池
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_RIGHT \
			and event.pressed \
			and held_clue_id != "":
		clear_slot()
