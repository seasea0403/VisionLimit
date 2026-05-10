extends Node2D

# ==================== 子节点引用 ====================
@onready var close_button = $CloseButton


# ==================== 初始化 ====================
func _ready() -> void:
	# 连接关闭按钮
	close_button.pressed.connect(_on_close_button_pressed)


# ==================== 关闭自身 ====================
func _on_close_button_pressed() -> void:
	"""
	关闭这个放大视图（从场景树移除自己）
	"""
	queue_free()
