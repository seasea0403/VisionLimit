# ch3_lock_area.gd
# ClickableArea_suo_2 专用脚本：先显示密码面板，解锁后再显示内层 Zoomview

extends "res://Script/Components/clickable_area.gd"


func _show_zoom_view() -> void:
	var password_panel := get_node_or_null("PasswordPanel_open")
	if password_panel:
		# 注册到章节面板栈，使 HUD Back 可关闭
		var chapter := _find_chapter()
		if chapter and chapter.has_method("register_panel_open"):
			chapter.register_panel_open(password_panel)
		# 密码正确后触发 Zoomview
		if not password_panel.password_correct.is_connected(_on_password_correct):
			password_panel.password_correct.connect(_on_password_correct, CONNECT_ONE_SHOT)
		password_panel.open()
	else:
		super._show_zoom_view()


func _on_password_correct() -> void:
	# 关闭密码面板
	var password_panel := get_node_or_null("PasswordPanel_open")
	if password_panel:
		password_panel.close()
	# 显示内层 Zoomview
	for child in get_children():
		if child.has_method("show_view"):
			var chapter := _find_chapter()
			if chapter and chapter.has_method("register_panel_open"):
				chapter.register_panel_open(child)
			child.show_view()
			return
