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
	# 通知 chapter 从栈中移除此面板
	var chapter := _find_chapter()
	if chapter and chapter.has_method("_unregister_panel"):
		chapter._unregister_panel(self)


# ==================== Back 按钮处理 ====================
func close_view() -> void:
	"""关闭缩放视图"""
	hide_view()


func _disable_other_area_inputs() -> void:
	_disabled_areas.clear()
	var root := get_tree().current_scene
	if not root:
		return
	# 找到 ZoomViews 根节点或当前 zoomview 的父节点，只在其范围内禁用
	var disable_root := _find_zoom_views_root()
	if disable_root:
		_disable_area_inputs_recursive(disable_root)


func _find_zoom_views_root() -> Node:
	"""找到 ZoomViews 根节点，如果找不到则返回当前节点的父节点"""
	var current: Node = self
	while current:
		# 向上查找 ZoomViews 节点
		if current.name == "ZoomViews":
			return current
		current = current.get_parent()
	
	# 如果找不到 ZoomViews，返回当前节点的父节点（即所属的 ClickableArea）
	return get_parent()


func _disable_area_inputs_recursive(node: Node) -> void:
	if node is Area2D:
		var area := node as Area2D
		# 不禁用自己及其子节点的 Area2D
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


func _find_chapter() -> Node:
	"""向上查找所属的 Chapter 节点"""
	var current: Node = self
	while current:
		if current.has_method("register_panel_open"):
			return current
		current = current.get_parent()
	return null
