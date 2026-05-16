extends Panel

# ==================== 子节点引用 ====================
@onready var password_panel = $VBoxContainer/PasswordPanel


# ==================== 初始化 ====================
func _ready() -> void:
	# 订阅密码正确事件
	if password_panel:
		password_panel.password_correct.connect(_on_password_correct)
	else:
		push_error("找不到 PasswordPanel 节点")


# ==================== 信号处理 ====================
func _on_password_correct() -> void:
	"""密码输入正确时调用"""
	print("✓ 密码输入正确，隐藏面板")
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
