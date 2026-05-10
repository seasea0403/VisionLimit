extends Area2D

# ==================== 配置参数 ====================
## 要弹出的 ZoomView 子场景路径（如 res://Scenes/ZoomViews/ZoomView_Desk.tscn）
@export var zoom_view_scene: PackedScene

## 主场景引用（用于 add_child）
var main_scene: Node2D


# ==================== 初始化 ====================
func _ready() -> void:
	# 连接点击信号
	input_event.connect(_on_input_event)


# ==================== 信号处理 ====================
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		# 实例化 ZoomView 子场景并添加到主场景
		if zoom_view_scene and main_scene:
			var zoom_instance = zoom_view_scene.instantiate()
			main_scene.add_child(zoom_instance)
			zoom_instance.z_index = 100  # 确保显示在最上面
