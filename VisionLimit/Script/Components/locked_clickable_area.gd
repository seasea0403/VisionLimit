extends Area2D

## 该物品对应的密码面板节点（每个物品可以指向不同的 PasswordPanel）
## 留空时会在父链中查找 UILayer/PasswordPanel 作为后备
@export var password_panel_path: NodePath

## 可选：覆盖面板上的密码。留空("")则使用该 PasswordPanel 自身 Inspector 配置的 correct_password
@export var correct_password: String = ""

## 解锁后是否记住状态（同一场景内再次点击不再要求密码）
@export var remember_unlock: bool = true

var _unlocked: bool = false


func _ready() -> void:
	input_event.connect(_on_input_event)


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if DialogueManager.is_active:
		return
	get_viewport().set_input_as_handled()

	if _unlocked and remember_unlock:
		_show_zoom_view()
		return

	var pp := _resolve_password_panel()
	if pp == null:
		push_error("LockedClickableArea: 找不到 PasswordPanel")
		return

	# 只在显式填写时覆盖，否则保留 PasswordPanel 自身 Inspector 里配置的密码
	if correct_password != "":
		pp.correct_password = correct_password
	# 一次性连接，避免多个 LockedClickableArea 互相串扰
	if not pp.password_correct.is_connected(_on_password_correct):
		pp.password_correct.connect(_on_password_correct, CONNECT_ONE_SHOT)
	pp.open()


func _on_password_correct() -> void:
	_unlocked = true
	_show_zoom_view()


# —— 复用 clickable_area.gd 的展开逻辑 ——
func _show_zoom_view() -> void:
	for child in get_children():
		if child.has_method("show_view"):
			var chapter := _find_chapter()
			if chapter and chapter.has_method("register_panel_open"):
				chapter.register_panel_open(child)
			child.show_view()
			return
	push_error("LockedClickableArea: 找不到有 show_view() 的 Zoomview 子节点")


func _find_chapter() -> Node:
	var node := get_parent()
	while node:
		if node.has_method("register_panel_open"):
			return node
		node = node.get_parent()
	return null


func _resolve_password_panel() -> Node:
	if password_panel_path != NodePath(""):
		var n := get_node_or_null(password_panel_path)
		if n: return n

	# 父链向上找一个 UILayer/PasswordPanel
	var node := get_parent()
	while node:
		var ui := node.get_node_or_null("UILayer/PasswordPanel")
		if ui: return ui
		if node.name == "UILayer":
			var p := node.get_node_or_null("PasswordPanel")
			if p: return p
		node = node.get_parent()
	return null
