extends Panel

## 密码正确后弹出的工单终端场景（在 Inspector 中拖入 2.tscn）
@export var terminal_scene: PackedScene

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
	"""密码输入正确 → 隐藏整个 1 节点（含背景），打开工单终端"""
	# 必须隐藏整个父节点 1（而非仅 password_1 Panel），
	# 否则 TextureRect 背景残留在 UILayer(layer=1) 会遮住 layer=0 的 2.tscn
	get_parent().hide()
	if terminal_scene:
		var terminal: Control = terminal_scene.instantiate()
		get_tree().get_root().add_child(terminal)
	else:
		push_warning("[password_1.gd] terminal_scene 未设置，请在 Inspector 中拖入 2.tscn")
