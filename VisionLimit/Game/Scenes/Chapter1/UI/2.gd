extends Control

# ==================== 工单数据 ====================
## 格式：number 患者编号, grade 紊乱等级(轻度/中度/重度), description 患者自述
var work_orders: Array[Dictionary] = [
	{"number": "0471", "grade": "轻度", "description": "患者反映偶发短暂记忆缺失，日常生活基本不受影响，无明显情绪异常。"},
	{"number": "0472", "grade": "中度", "description": "患者出现连续记忆断层，无法回忆近三日内事件，情绪波动明显加剧。"},
	{"number": "0473", "grade": "重度", "description": "患者重度紊乱，长期海芯写入异常，伴随情景记忆混叠。海芯功能异常。"},
	{"number": "0474", "grade": "轻度", "description": "患者偶有记忆混乱，早期海芯写入量轻微偏高，未出现明显行为异常。"},
	{"number": "0475", "grade": "中度", "description": "患者记忆开始出现幻觉性回忆，将虚构事件与真实事件混淆，建议接入托管。"},
	{"number": "0476", "grade": "重度", "description": "患者系化学行业科研工作者，海芯写入量严重超标导致昏迷，职业病典型案例"},
]


## 当前选中工单索引，-1 表示未选中
var current_order_index: int = -1

## 已成功完成分配的工单数量
var completed_orders: int = 0

## 三位托管师固定等级：一级/二级/三级
var guardian_grades: Array[int] = [1, 2, 3]

# ==================== 可配置项 ====================
## 系统日志字体（在 Inspector 中赋值）
@export var log_font: Font

## 系统日志字体大小
@export var log_font_size: int = 20

## 弹窗标题文字
@export var popup_title: String = "系统提示"

## 等级匹配错误时的弹窗正文（{required} 会被替换为所需等级，{actual} 会被替换为托管师等级）
@export_multiline var error_message: String = "等级匹配错误！\n该案例需要 {required} 级或以上执照，\n当前托管师仅为 {actual} 级。"

## 自定义错误弹窗预制体（拖入 ErrorPopup.tscn）
@export var error_popup_scene: PackedScene

## 章节完成后弹出的面板（拖入 3.tscn）
@export var chapter_complete_panel_scene: PackedScene

# ==================== 节点引用 ====================
@onready var work_order_items: Array = [
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Left/VBoxContainer/WorkOrderItem,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Left/VBoxContainer/WorkOrderItem2,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Left/VBoxContainer/WorkOrderItem3,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Left/VBoxContainer/WorkOrderItem4,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Left/VBoxContainer/WorkOrderItem5,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Left/VBoxContainer/WorkOrderItem6,
]

@onready var detail_number_label: Label = $ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/number
@onready var detail_grade_label:  Label = $ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/grade
@onready var detail_desc_label:   Label = $ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/LabelDesc

@onready var guardian_grade_labels: Array = [
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/HBoxContainer/first/Label,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/HBoxContainer/second/Label,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/HBoxContainer/third/Label,
]

@onready var assign_buttons: Array = [
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/HBoxContainer/first/Assign,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/HBoxContainer/second/Assign,
	$ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Middle/VBoxContainer2/HBoxContainer/third/Assign,
]

@onready var log_container: VBoxContainer = $ColorRect/MarginContainer/VBoxContainer/content/HBoxContainer/Right/RightInner/LogContainer


# ==================== 初始化 ====================
func _ready() -> void:
	# 初始化工单列表
	for i in work_order_items.size():
		work_order_items[i].setup(i, work_orders[i]["number"], work_orders[i]["grade"])
		work_order_items[i].order_selected.connect(_on_work_order_selected)

	# 连接分配按钮
	for i in assign_buttons.size():
		var idx := i
		assign_buttons[i].pressed.connect(func(): _on_assign_pressed(idx))


# ==================== 工单点击 ====================
func _on_work_order_selected(index: int) -> void:
	current_order_index = index
	var order := work_orders[index]
	detail_number_label.text = "患者编号：" + order["number"]
	detail_grade_label.text  = "记忆紊乱等级：" + order["grade"]
	detail_desc_label.text   = "患者自述：" + order["description"]


# ==================== 分配 ====================
func _on_assign_pressed(guardian_index: int) -> void:
	if current_order_index < 0:
		_show_error("请先在左侧选择一个工单！")
		return

	if work_order_items[current_order_index].is_assigned:
		_show_error("该工单已完成分配！")
		return

	var order        := work_orders[current_order_index]
	var required     := _required_grade(order["grade"])
	var guardian_lvl := guardian_grades[guardian_index]

	if guardian_lvl >= required:
		# ✅ 匹配成功
		work_order_items[current_order_index].mark_assigned()
		_add_log(order, guardian_lvl)

		# 检查是否所有工单都已完成
		completed_orders += 1
		if completed_orders >= work_order_items.size():
			await get_tree().create_timer(0.8).timeout
			_trigger_chapter_complete()
	else:
		# ❌ 等级不足
		var msg := error_message.replace("{required}", str(required)).replace("{actual}", str(guardian_lvl))
		_show_error(msg)


# ==================== 辅助函数 ====================
## 根据紊乱等级返回所需最低执照级别
func _required_grade(disorder: String) -> int:
	match disorder:
		"轻度": return 1
		"中度": return 2
		"重度": return 3
	return 1


## 向右侧系统日志区域追加一条记录
func _add_log(order: Dictionary, guardian_lvl: int) -> void:
	var entry := Label.new()
	entry.text          = "[%s] 患者 %s（%s紊乱）→ %d级托管师 已分配" % [
		_timestamp(), order["number"], order["grade"], guardian_lvl
	]
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1, 1))
	if log_font:
		entry.add_theme_font_override("font", log_font)
		entry.add_theme_font_size_override("font_size", log_font_size)
	log_container.add_child(entry)


## 弹出错误提示弹窗
func _show_error(message: String) -> void:
	if error_popup_scene:
		# 使用自定义弹窗场景
		var popup = error_popup_scene.instantiate()
		add_child(popup)
		popup.show_popup(popup_title, message)
		popup.confirmed.connect(popup.queue_free)
	else:
		# 备用：未设置自定义弹窗时回落 AcceptDialog
		var popup := AcceptDialog.new()
		popup.title       = popup_title
		popup.dialog_text = message
		add_child(popup)
		popup.popup_centered()
		popup.confirmed.connect(popup.queue_free)


## 返回简易时间戳字符串（用于日志显示）
func _timestamp() -> String:
	var t := Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [t["hour"], t["minute"], t["second"]]


# ==================== 章节完成触发 ====================
## 所有工单分配完成后，弹出 3.tscn 流程面板
func _trigger_chapter_complete() -> void:
	if chapter_complete_panel_scene:
		var panel: Control = chapter_complete_panel_scene.instantiate()
		get_tree().get_root().add_child(panel)
		queue_free()
	else:
		push_warning("[2.gd] chapter_complete_panel_scene 未设置，请在 Inspector 中拖入 3.tscn")
