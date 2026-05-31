extends Control

# ==================== 状态枚举 ====================
enum State { ICONS, BROWSER, PASSWORD, BANKING_RECORDS }

# ==================== 可配置项 ====================
## 密码面板场景（在 Inspector 中拖入 1.tscn）
@export var password_panel_scene: PackedScene

# ==================== 节点引用 ====================
## 桌面图标层（包含浏览器图标和网银图标）
@onready var desktop_icons: Control = $DesktopIcons
@onready var browser_icon: TextureButton = $DesktopIcons/BrowserIcon
@onready var banking_icon: TextureButton = $DesktopIcons/BankingIcon

## 浏览器视图（显示 0-电脑-浏览器页面.png）
@onready var browser_view: Control = $BrowserView

## 银行记录视图（BankingRecords.gd）
@onready var banking_records: Control = $BankingRecords

# ==================== 私有变量 ====================
var _state: State = State.ICONS
## 运行时实例化的 1.tscn（密码面板）
var _password_instance: Control = null


# ==================== 初始化 ====================
func _ready() -> void:
	# Desktop 根节点的 back 由 HUD 负责（computer_trigger 已 register_panel_open），永久隐藏
	var root_back := get_node_or_null("back") as Control
	if root_back:
		root_back.hide()

	browser_icon.pressed.connect(_on_browser_pressed)
	banking_icon.pressed.connect(_on_banking_pressed)

	# 浏览器视图自己的 back 按钮 → 仅关闭浏览器，返回桌面图标
	var bv_back: TextureButton = browser_view.get_node_or_null("back/TextureButton") as TextureButton
	if bv_back:
		bv_back.pressed.connect(_show_desktop)
	else:
		push_warning("[Desktop.gd] 未找到 BrowserView/back/TextureButton")

	# 银行记录视图自己的 back 信号 → 仅关闭银行记录，返回桌面图标
	banking_records.back_pressed.connect(_show_desktop)

	_show_desktop()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible and is_node_ready():
			_show_desktop()


# ==================== 状态切换 ====================
func _show_desktop() -> void:
	_state = State.ICONS
	desktop_icons.show()
	browser_view.hide()
	banking_records.hide()
	if is_instance_valid(_password_instance):
		_password_instance.hide()


func _on_browser_pressed() -> void:
	_state = State.BROWSER
	desktop_icons.hide()
	browser_view.show()


func _on_banking_pressed() -> void:
	_state = State.PASSWORD
	desktop_icons.hide()

	# 首次点击时实例化 1.tscn 并连接信号
	if not is_instance_valid(_password_instance):
		if not password_panel_scene:
			push_warning("[Desktop.gd] password_panel_scene 未设置，请在 Inspector 中拖入 1.tscn")
			return
		_password_instance = password_panel_scene.instantiate() as Control
		add_child(_password_instance)

		# 连接 1.tscn 内 back 按钮：按下时返回桌面图标视图
		# 注意：不能用 visibility_changed，因为 password_1.gd 的 _on_password_correct 会先
		# 调用 get_parent().hide()，再 emit password_confirmed，导致状态被错误重置
		var pw_back: TextureButton = _password_instance.get_node_or_null("back/TextureButton") as TextureButton
		if pw_back:
			pw_back.pressed.connect(_show_desktop)
		else:
			push_warning("[Desktop.gd] 未找到 1.tscn 的 back/TextureButton 节点")

		# 连接 password_confirmed 信号 → 切换到银行记录视图
		var pw: Node = _password_instance.get_node_or_null("password_1")
		if pw and pw.has_signal("password_confirmed"):
			if not pw.password_confirmed.is_connected(_on_password_confirmed):
				pw.password_confirmed.connect(_on_password_confirmed)
		else:
			push_warning("[Desktop.gd] 未找到 password_1 节点或 password_confirmed 信号")

	_password_instance.show()


# 密码正确信号 → 状态切换到银行记录（password_1.gd 已将 1.tscn 根节点隐藏）
func _on_password_confirmed() -> void:
	_state = State.BANKING_RECORDS
	banking_records.show()
