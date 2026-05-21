extends Node2D

var _disabled_areas: Array[Area2D] = []

## 进入 ZoomView 时是否弹出 ItemDetail
@export var show_detail_on_open: bool = false
## ItemDetail 标题
@export var detail_title: String = ""
## ItemDetail 描述文字
@export_multiline var detail_description: String = ""
## 说话人角色图片
@export var detail_character_image: Texture2D = null


# ==================== 初始化 ====================
func _ready() -> void:
	pass


# ==================== 对外接口 ====================
func show_view() -> void:
	show()
	_disable_other_area_inputs()
	if show_detail_on_open:
		_show_entry_detail()


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


# ==================== 禁用/恢复背景点击 ====================
func _disable_other_area_inputs() -> void:
	_disabled_areas.clear()
	# 从整个场景根节点遍历，禁用所有不属于本 ZoomView 的 Area2D
	var root := get_tree().current_scene
	if root:
		_disable_area_inputs_recursive(root)


func _disable_area_inputs_recursive(node: Node) -> void:
	if node is Area2D:
		var area := node as Area2D
		# 不禁用本 ZoomView 自身及其子孙节点内的 Area2D
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


# ==================== 进入时弹出 ItemDetail ====================
func _show_entry_detail() -> void:
	"""进入 ZoomView 时弹出 ItemDetail（可配置）"""
	var chapter := _find_chapter()
	if not chapter:
		return
	var item_detail = chapter.get("item_detail")
	if not item_detail or not item_detail.has_method("show_detail"):
		return
	item_detail.show_detail(
		null,
		detail_description,
		detail_title,
		false, "", Vector2.ONE, Vector2.ZERO,
		"", "", "", "",
		detail_character_image
	)
	# 隐藏暗色背景（ZoomView 场景下背景已是 ZoomView 本身，不需要遮罩）
	if item_detail.has_method("set_dark_background_visible"):
		item_detail.set_dark_background_visible(false)


func _find_chapter() -> Node:
	"""向上查找所属的 Chapter 节点"""
	var current: Node = self
	while current:
		if current.has_method("register_panel_open"):
			return current
		current = current.get_parent()
	return null
