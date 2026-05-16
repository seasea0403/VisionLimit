extends Area2D

## 电脑点击后显示的密码终端（在 Inspector 中拖入 Chapter1 UILayer 下的 1 节点）
@export var terminal_panel: Control


func _ready() -> void:
	input_event.connect(_on_input_event)


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		if terminal_panel:
			terminal_panel.show()
			# 注册到 chapter 的面板栈，使 HUD back 按钮能关闭此界面
			var chapter := _find_chapter()
			if chapter:
				chapter.register_panel_open(terminal_panel)
		else:
			push_warning("[computer_trigger.gd] terminal_panel 未设置")


## 向上查找含有 register_panel_open 方法的 Chapter 节点
func _find_chapter() -> Node:
	var node := get_parent()
	while node:
		if node.has_method("register_panel_open"):
			return node
		node = node.get_parent()
	return null
