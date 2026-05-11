extends Area2D

# ==================== 初始化 ====================
func _ready() -> void:	
	# 连接点击信号
	input_event.connect(_on_input_event)


# ==================== 信号处理 ====================
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("点击区域：", self.name)
		_show_zoom_view()


func _show_zoom_view() -> void:
	# 遍历所有子节点，找到有 show_view 方法的（即 ZoomView）
	for child in get_children():
		if child.has_method("show_view"):
			print("✓ 显示 ZoomView: ", child.name)
			child.show_view()
			return
	
	print("✗ 错误：找不到有效的 ZoomView 子节点")
