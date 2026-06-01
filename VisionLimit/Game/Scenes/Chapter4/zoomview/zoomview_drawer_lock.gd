extends "res://Script/Components/zoomview.gd"

# ==================== 状态 ====================
## 谜题是否已解开（重进章节时重置）
var _puzzle_solved: bool = false

# ==================== 子节点引用 ====================
## 密码页面
@onready var _password_panel: Control = $Items/PasswordPanel
## 抽屉内容（通常是 items 目录下的 PackScene 实例化节点）
@onready var _drawer_content: Node2D = $Items.get_child(1) if $Items.get_child_count() > 1 else null

# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()
	
	# 初始状态：抽屉内容隐藏
	if _drawer_content:
		_drawer_content.hide()
		if _drawer_content is Area2D:
			_drawer_content.input_pickable = false
	
	# 连接密码正确信号
	if _password_panel:
		if not _password_panel.is_connected("password_correct", _on_password_correct):
			_password_panel.password_correct.connect(_on_password_correct)


# ==================== 覆盖 show_view ====================
func show_view() -> void:
	print(name, ": show_view called, solved=", _puzzle_solved)
	
	if _puzzle_solved:
		# 谜题已解：正常显示 ZoomView (这时背景是 drawer.png，子节点是 A2/B2 物品)
		show()
		_disable_other_area_inputs()
		if _drawer_content:
			_drawer_content.show()
			if _drawer_content is Area2D:
				_drawer_content.input_pickable = true
		if _password_panel:
			_password_panel.hide()
		return

	# 谜题未解：显示 Zoomview，但盖上 PasswordPanel
	show()
	_disable_other_area_inputs()
	if _password_panel:
		_password_panel.show()
		if _password_panel.has_method("open"):
			_password_panel.open()
	if _drawer_content:
		_drawer_content.hide()


# ==================== 密码解锁回调 ====================
func _on_password_correct() -> void:
	print(name, ": _on_password_correct received")
	_puzzle_solved = true
	
	if _password_panel:
		_password_panel.hide()
	
	if _drawer_content:
		_drawer_content.show()
		if _drawer_content is Area2D:
			_drawer_content.input_pickable = true
	
	# 如果在这个阶段你想直接自动显示内容可以加逻辑，
	# 但由于抽屉打开通常是由于“点击抽屉”这个动作触发缩放，
	# 解密后留在缩放图看里面的东西是符合直觉的。
