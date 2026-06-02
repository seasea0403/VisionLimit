# ch3_door_left_area.gd
# ClickableArea_Door_Right（左门内层）专用脚本
# 首次点击 → 显示密码面板；解锁后 → 直接弹出进入病房选项

extends "res://Script/Components/clickable_area.gd"

const _STATE_KEY := "ch3_door_unlocked"


func _show_zoom_view() -> void:
	# 已解锁：直接弹出选择框（不再显示密码面板）
	if GameStateManager.get_record(_STATE_KEY) == "true":
		_call_chapter_choice()
		return

	# 首次进入：仅显示密码面板，不显示 Zoomview
	var pw := get_node_or_null("PasswordPanel")
	if pw:
		var chapter := _find_chapter()
		if chapter and chapter.has_method("register_panel_open"):
			chapter.register_panel_open(pw)
		if not pw.password_correct.is_connected(_on_password_correct):
			pw.password_correct.connect(_on_password_correct, CONNECT_ONE_SHOT)
		pw.open()


func _on_password_correct() -> void:
	var pw := get_node_or_null("PasswordPanel")
	if pw:
		pw.close()
	GameStateManager.set_record(_STATE_KEY, "true")
	_call_chapter_choice()


func _call_chapter_choice() -> void:
	var chapter := _find_chapter()
	if chapter and chapter.has_method("start_door_choice_dialogue"):
		chapter.call("start_door_choice_dialogue")
