extends Control

signal timeline_completed

@export var completion_chapter_index: int = 4
@export var completion_title_text: String = "时间轴归档已完成"
@export var completion_desc_text: String = "四份档案已经按年份归位，真正被移动的是证据的顺序。"

const MATERIAL_META: Dictionary = {
	"A": {"year": "2039", "title": "苍屿精炼有限公司", "detail": "临深集团旗下，竣工投产"},
	"B": {"year": "2041", "title": "荣誉附件", "detail": "临深集团配合检测情况说明"},
	"C": {"year": "2042", "title": "外业勘测日志", "detail": "陈星河签名痕迹"},
	"D": {"year": "2043", "title": "正源环境检测有限公司", "detail": "挂牌成立，承接检测服务"},
}

const SLOT_META: Dictionary = {
	"A": {"year": "2042"},
	"B": {"year": "2039"},
	"C": {"year": "2043"},
	"D": {"year": "2041"},
}

@onready var title_label: Label = $Center/PhonePanel/Margin/MainVBox/Header/HeaderMargin/HeaderRow/TitleStack/TitleLabel
@onready var subtitle_label: Label = $Center/PhonePanel/Margin/MainVBox/Header/HeaderMargin/HeaderRow/TitleStack/SubtitleLabel
@onready var progress_label: Label = $Center/PhonePanel/Margin/MainVBox/Header/HeaderMargin/HeaderRow/ProgressLabel
@onready var status_label: Label = $Center/PhonePanel/Margin/MainVBox/Footer/FooterMargin/FooterRow/InfoStack/StatusLabel
@onready var hint_label: Label = $Center/PhonePanel/Margin/MainVBox/Footer/FooterMargin/FooterRow/InfoStack/HintLabel
@onready var reset_button: Button = $Center/PhonePanel/Margin/MainVBox/Footer/FooterMargin/FooterRow/ResetButton
@onready var complete_overlay: Control = $CompleteOverlay
@onready var complete_title_label: Label = $CompleteOverlay/Center/CompleteCard/CompleteMargin/CompleteStack/CompleteTitleLabel
@onready var complete_desc_label: Label = $CompleteOverlay/Center/CompleteCard/CompleteMargin/CompleteStack/CompleteDescLabel
@onready var complete_button: Button = $CompleteOverlay/Center/CompleteCard/CompleteMargin/CompleteStack/CompleteButton

@onready var material_a: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/LeftColumn/MaterialA
@onready var material_b: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/LeftColumn/MaterialB
@onready var material_c: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/LeftColumn/MaterialC
@onready var material_d: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/LeftColumn/MaterialD
@onready var slot_a1: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/RightColumn/SlotA1
@onready var slot_a2: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/RightColumn/SlotA2
@onready var slot_b1: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/RightColumn/SlotB1
@onready var slot_b2: Button = $Center/PhonePanel/Margin/MainVBox/Board/BoardMargin/BoardRoot/ColumnsRow/RightColumn/SlotB2

var _material_buttons: Dictionary = {}
var _slot_buttons: Dictionary = {}
var _material_to_slot: Dictionary = {}
var _slot_to_material: Dictionary = {}
var _selected_material_id: String = ""
var _completed: bool = false


func _ready() -> void:
	_material_buttons = {
		"A": material_a,
		"B": material_b,
		"C": material_c,
		"D": material_d,
	}
	_slot_buttons = {
		"A": slot_a1,
		"B": slot_a2,
		"C": slot_b1,
		"D": slot_b2,
	}

	title_label.text = "时间轴归档"
	subtitle_label.text = "按年份把材料重新归位；放错会退回，归位后会自动核验"
	hint_label.text = "先点材料，再点年份格；可反复重排"
	progress_label.text = "0 / 4"
	status_label.text = ""
	complete_title_label.text = completion_title_text
	complete_desc_label.text = completion_desc_text
	complete_overlay.visible = false

	for material_id in _material_buttons.keys():
		var material_button: Button = _material_buttons[material_id]
		if material_button:
			material_button.pressed.connect(Callable(self, "_on_material_pressed").bind(material_id))

	for slot_id in _slot_buttons.keys():
		var slot_button: Button = _slot_buttons[slot_id]
		if slot_button:
			slot_button.pressed.connect(Callable(self, "_on_slot_pressed").bind(slot_id))

	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if complete_button:
		complete_button.pressed.connect(_on_complete_button_pressed)

	_refresh_ui()
	set_process(false)


func _on_material_pressed(material_id: String) -> void:
	if _completed:
		return

	if _selected_material_id == material_id:
		_selected_material_id = ""
		_set_status("已取消选择")
		_refresh_ui()
		return

	_selected_material_id = material_id
	_set_status("已选中 %s" % str(MATERIAL_META[material_id]["title"]))
	_refresh_ui()


func _on_slot_pressed(slot_id: String) -> void:
	if _completed:
		return

	if _selected_material_id == "":
		if _slot_to_material.has(slot_id):
			_selected_material_id = str(_slot_to_material[slot_id])
			_set_status("已选中 %s，继续调整位置" % str(MATERIAL_META[_selected_material_id]["title"]))
			_refresh_ui()
			return
		_set_status("先点材料，再点年份格")
		_flash_slot(slot_id, Color(0.96, 0.54, 0.54, 1.0))
		return

	var material_id: String = _selected_material_id
	var expected_slot: String = _get_correct_slot(material_id)
	if slot_id != expected_slot:
		_set_status("%s 不属于 %s" % [str(MATERIAL_META[material_id]["title"]), str(SLOT_META[slot_id]["year"])])
		_flash_slot(slot_id, Color(0.96, 0.54, 0.54, 1.0))
		return

	_place_material(material_id, slot_id)
	_selected_material_id = ""
	_set_status("%s 已归入 %s" % [str(MATERIAL_META[material_id]["title"]), str(SLOT_META[slot_id]["year"])])
	_refresh_ui()
	_check_completion()


func _place_material(material_id: String, slot_id: String) -> void:
	var previous_slot: String = str(_material_to_slot.get(material_id, ""))
	if previous_slot != "":
		_slot_to_material.erase(previous_slot)

	var previous_material: String = str(_slot_to_material.get(slot_id, ""))
	if previous_material != "":
		_material_to_slot.erase(previous_material)

	_material_to_slot[material_id] = slot_id
	_slot_to_material[slot_id] = material_id


func _refresh_ui() -> void:
	var completed_count: int = 0

	for material_id in MATERIAL_META.keys():
		var material_button: Button = _material_buttons[material_id]
		if material_button == null:
			continue

		var meta: Dictionary = MATERIAL_META[material_id]
		var assigned_slot: String = str(_material_to_slot.get(material_id, ""))
		var text_lines: PackedStringArray = ["%s  %s" % [material_id, str(meta["title"])], str(meta["detail"])]
		if assigned_slot != "":
			text_lines.append("→ %s / %s" % [assigned_slot, str(SLOT_META[assigned_slot]["year"])])
		material_button.text = "\n".join(text_lines)
		material_button.self_modulate = Color(1, 1, 1, 1)
		if assigned_slot != "":
			completed_count += 1
			material_button.self_modulate = Color(0.78, 0.95, 0.78, 1)
		if _selected_material_id == material_id:
			material_button.self_modulate = Color(0.98, 0.88, 0.50, 1)

	for slot_id in SLOT_META.keys():
		var slot_button: Button = _slot_buttons[slot_id]
		if slot_button == null:
			continue

		var slot_meta: Dictionary = SLOT_META[slot_id]
		var occupant: String = str(_slot_to_material.get(slot_id, ""))
		var slot_text_lines: PackedStringArray = ["%s  %s" % [slot_id, str(slot_meta["year"])]]
		if occupant != "":
			slot_text_lines.append("已归档：%s" % str(MATERIAL_META[occupant]["title"]))
		else:
			slot_text_lines.append("空位")
		slot_button.text = "\n".join(slot_text_lines)
		slot_button.self_modulate = Color(1, 1, 1, 1)
		if occupant != "":
			slot_button.self_modulate = Color(0.78, 0.95, 0.78, 1)

	progress_label.text = "%d / 4" % completed_count


func _check_completion() -> void:
	if _completed:
		return

	for material_id in MATERIAL_META.keys():
		if str(_material_to_slot.get(material_id, "")) != _get_correct_slot(material_id):
			return

	_completed = true
	progress_label.text = "4 / 4"
	status_label.text = completion_title_text
	complete_desc_label.text = completion_desc_text
	complete_overlay.visible = true
	timeline_completed.emit()
	if has_node("/root/GameStateManager"):
		GameStateManager.complete_chapter(completion_chapter_index)


func _get_correct_slot(material_id: String) -> String:
	var material_year: String = str(MATERIAL_META[material_id]["year"])
	for slot_id in SLOT_META.keys():
		if str(SLOT_META[slot_id]["year"]) == material_year:
			return slot_id
	return ""


func _on_reset_pressed() -> void:
	if _completed:
		_completed = false
		complete_overlay.visible = false

	_selected_material_id = ""
	_material_to_slot.clear()
	_slot_to_material.clear()
	_set_status("已清空归档")
	_refresh_ui()


func _on_complete_button_pressed() -> void:
	complete_overlay.visible = false


func _flash_slot(slot_id: String, flash_color: Color) -> void:
	var slot_button: Button = _slot_buttons.get(slot_id, null)
	if slot_button == null:
		return

	var tween: Tween = create_tween()
	tween.tween_property(slot_button, "self_modulate", flash_color, 0.08)
	tween.tween_property(slot_button, "self_modulate", Color(1, 1, 1, 1), 0.18)


func _set_status(text: String) -> void:
	status_label.text = text
