extends Button

# ==================== 信号 ====================
signal order_selected(index: int)

# ==================== 节点引用 ====================
@onready var name_label: Label   = $MarginContainer/HBoxContainer/VBoxContainer/name
@onready var grade_label: Label  = $MarginContainer/HBoxContainer/VBoxContainer/catagory
@onready var state_label: Label  = $MarginContainer/HBoxContainer/state

# ==================== 状态 ====================
var order_index: int = 0
var is_assigned: bool = false


# ==================== 初始化 ====================
func setup(index: int, number: String, grade: String) -> void:
	order_index = index
	name_label.text  = "患者编号：" + number
	grade_label.text = "紊乱类型：" + grade
	pressed.connect(func(): order_selected.emit(order_index))


# ==================== 公开接口 ====================
## 标记为已分配（橙色）
func mark_assigned() -> void:
	if is_assigned:
		return
	is_assigned = true
	state_label.text = "已分配"

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.55, 0.0, 1)
	style.corner_radius_top_left    = 5
	style.corner_radius_top_right   = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left  = 5
	style.expand_margin_left   = 10.0
	style.expand_margin_top    = 5.0
	style.expand_margin_right  = 10.0
	style.expand_margin_bottom = 5.0
	state_label.add_theme_stylebox_override("normal", style)
