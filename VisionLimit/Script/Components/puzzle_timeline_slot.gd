class_name PuzzleTimelineSlot

extends Control

## 时间轴谜题——接受卡片拖入的槽位
## 在编辑器中调整位置/尺寸，只需设置 expected_card_id 即可

@export var expected_card_id: int = 0

var is_filled: bool = false

signal slot_filled


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


# ─── Godot 内置拖拽协议 ──────────────────────────────────────────────────────

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return (not is_filled) and (data is Dictionary) and data.has("card_id")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not (data is Dictionary and data.has("card_id")):
		return
	var card := data.get("card") as PuzzleEventCard
	if data["card_id"] == expected_card_id:
		# 正确匹配
		is_filled = true
		if card:
			card.snap_to_slot(global_position, size)
		slot_filled.emit()
	else:
		# 匹配失败：卡片飞入槽位→闪红→弹回原位
		if card:
			card.reject_from_slot(global_position, size)

