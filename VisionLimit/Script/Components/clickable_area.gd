extends Area2D

# ==================== 初始化 ====================
func _ready() -> void:	
	# 连接点击信号
	input_event.connect(_on_input_event)


# ==================== 信号处理 ====================
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		print("点击区域：", self.name)
		_show_zoom_view()


func _show_zoom_view() -> void:
	for child in get_children():
		if child.has_method("show_view"):
			child.show_view()
			# 通知 chapter 追踪当前打开的面板
			var chapter := _find_chapter()
			if chapter and chapter.has_method("register_panel_open"):
				chapter.register_panel_open(child)
			return
	print("✗ 错误：找不到有效的 ZoomView 子节点")


func _find_chapter() -> Node:
	var node := get_parent()
	while node:
		if node.has_method("register_panel_open"):
			return node
		node = node.get_parent()
	return null
