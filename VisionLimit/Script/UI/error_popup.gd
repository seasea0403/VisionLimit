extends CanvasLayer

# ==================== 节点引用 ====================
## 面板本体（调整大小和背景）
@onready var panel = $Node2D
## 标题标签
@onready var title_label: Label = $Node2D/Title
## 正文内容标签
@onready var content_label: Label = $Node2D/Content
## 确认按钮
@onready var confirm_button: Button = $Node2D/ConfirmButton

# ==================== 信号 ====================
signal confirmed()


# ==================== 初始化 ====================
func _ready() -> void:
	confirm_button.pressed.connect(_on_confirmed)
	hide()


# ==================== 公开接口 ====================
## 显示弹窗，title 标题，message 正文
func show_popup(title: String, message: String) -> void:
	title_label.text   = title
	content_label.text = message
	show()


## 关闭弹窗
func close() -> void:
	hide()
	confirmed.emit()


# ==================== 事件处理 ====================
func _on_confirmed() -> void:
	close()


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
