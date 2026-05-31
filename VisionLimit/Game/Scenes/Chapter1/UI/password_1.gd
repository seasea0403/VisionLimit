extends Panel

## 密码正确后，若由外部场景（如 Desktop）监听此信号，则交由外部处理；
## 否则走旧流程：实例化 terminal_scene 并添加到场景树根节点
signal password_confirmed

## 密码正确后弹出的工单终端场景（旧流程保留；由 Desktop 管理时留空即可）
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


# 每次整个 UI/1 重新变为可见时，重置并重新展示密码面板
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		if password_panel:
			password_panel.open()


# ==================== 信号处理 ====================
func _on_password_correct() -> void:
	"""密码输入正确 → 隐藏整个 1 节点（含背景），发出 password_confirmed 信号"""
	# 必须隐藏整个父节点 1（而非仅 password_1 Panel），
	# 否则 TextureRect 背景残留在 UILayer(layer=1) 会遮住后续面板
	get_parent().hide()
	password_confirmed.emit()
	# 旧流程兼容：若 terminal_scene 有值且无外部监听者，则自行实例化
	if terminal_scene and password_confirmed.get_connections().is_empty():
		var terminal: Control = terminal_scene.instantiate()
		get_tree().get_root().add_child(terminal)
