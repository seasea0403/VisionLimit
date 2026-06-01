class_name PuzzleEventCard

extends TextureRect

## 时间轴谜题——可拖拽的事件卡片
## 在编辑器中调整位置/尺寸，只需设置 card_id 即可

@export var card_id: int = 0

var home_position: Vector2 = Vector2.ZERO  # _ready() 时自动记录
var is_placed: bool = false                 # 已正确放入槽位后禁止再拖


func _ready() -> void:
	# 记录初始中心位置（供弹回使用）
	home_position = position + size / 2.0
	mouse_filter  = Control.MOUSE_FILTER_STOP


# ─── 拖拽开始 ────────────────────────────────────────────────────────────────

func _get_drag_data(_at_position: Vector2) -> Variant:
	if is_placed:
		return null
	# 生成半透明预览
	var preview := TextureRect.new()
	preview.texture      = texture
	preview.expand_mode  = expand_mode
	preview.stretch_mode = stretch_mode
	preview.size         = size
	preview.modulate     = Color(1.0, 1.0, 1.0, 0.8)
	set_drag_preview(preview)
	return {"card_id": card_id, "card": self}


# ─── 错误放置：飞入槽位→变红闪烁→弹回原位 ────────────────────────────────

func reject_from_slot(slot_global_pos: Vector2, slot_size: Vector2) -> void:
	visible = true
	z_index = 2
	var snap_target := slot_global_pos + slot_size / 2.0 - size / 2.0
	var home_target := home_position - size / 2.0
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	# 1. 飞入槽位
	tw.tween_property(self, "global_position", snap_target, 0.15)
	# 2. 闪红两次
	tw.tween_property(self, "modulate", Color(1.0, 0.25, 0.25, 1.0), 0.10)
	tw.tween_property(self, "modulate", Color.WHITE,                 0.08)
	tw.tween_property(self, "modulate", Color(1.0, 0.25, 0.25, 1.0), 0.10)
	tw.tween_property(self, "modulate", Color.WHITE,                 0.08)
	# 3. 弹回原位
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "global_position", home_target, 0.40)
	tw.tween_callback(func(): z_index = 0)


# ─── 吸附到槽位（正确放置时由 slot 调用）────────────────────────────────────

func snap_to_slot(slot_global_pos: Vector2, slot_size: Vector2) -> void:
	is_placed    = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index      = 1
	var target := slot_global_pos + slot_size / 2.0 - size / 2.0
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", target, 0.2)
