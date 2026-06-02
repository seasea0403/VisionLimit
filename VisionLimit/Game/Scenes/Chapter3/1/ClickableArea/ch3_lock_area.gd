# ch3_lock_area.gd
# ClickableArea_suo_2 专用脚本：先显示密码面板，解锁后再直接显示内层 Zoomview

extends "res://Script/Components/clickable_area.gd"

const _STATE_KEY := "ch3_suo2_unlocked"


func _show_zoom_view() -> void:
	# 已解锁：直接显示内层 Zoomview
	if GameStateManager.get_record(_STATE_KEY) == "true":
		_show_inner_zoomview()
		return

	# 首次进入：先显示密码面板
	var password_panel := get_node_or_null("PasswordPanel_open")
	if password_panel:
		var chapter := _find_chapter()
		if chapter and chapter.has_method("register_panel_open"):
			chapter.register_panel_open(password_panel)
		if not password_panel.password_correct.is_connected(_on_password_correct):
			password_panel.password_correct.connect(_on_password_correct, CONNECT_ONE_SHOT)
		password_panel.open()
	else:
		super._show_zoom_view()


func _on_password_correct() -> void:
	GameStateManager.set_record(_STATE_KEY, "true")
	var password_panel := get_node_or_null("PasswordPanel_open")
	if password_panel:
		password_panel.close()
	_show_inner_zoomview()


func _show_inner_zoomview() -> void:
	for child in get_children():
		if child.has_method("show_view"):
			var chapter := _find_chapter()
			if chapter and chapter.has_method("register_panel_open"):
				chapter.register_panel_open(child)
			child.show_view()
			return
