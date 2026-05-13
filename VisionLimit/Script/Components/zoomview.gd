extends Node2D

var _disabled_areas: Array[Area2D] = []


# ==================== 初始化 ====================
func _ready() -> void:
	pass


# ==================== 对外接口 ====================
func show_view() -> void:
	show()
	_disable_other_area_inputs()


func open_view() -> void:
	"""打开缩放视图（同 show_view）"""
	show_view()


func hide_view() -> void:
	hide()
	_restore_disabled_area_inputs()


# ==================== Back 按钮处理 ====================
func close_view() -> void:
	"""关闭缩放视图"""
	hide_view()


func _disable_other_area_inputs() -> void:
	_disabled_areas.clear()
	var root := get_tree().current_scene
	if not root:
		return
	_disable_area_inputs_recursive(root)


func _disable_area_inputs_recursive(node: Node) -> void:
	if node is Area2D:
		var area := node as Area2D
		if not _is_descendant_of(area, self) and area.input_pickable:
			area.input_pickable = false
			_disabled_areas.append(area)

	for child in node.get_children():
		_disable_area_inputs_recursive(child)


func _restore_disabled_area_inputs() -> void:
	for area in _disabled_areas:
		if is_instance_valid(area):
			area.input_pickable = true
	_disabled_areas.clear()


func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	var current: Node = node
	while current:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false
