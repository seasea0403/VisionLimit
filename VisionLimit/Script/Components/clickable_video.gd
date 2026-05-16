extends Area2D

# ==================== 配置参数 ====================
## 视频文件路径（例如：res://Art/Videos/demo.mp4）
@export var video_path: String = ""

## 视频名称（用于日志）
@export var video_name: String = "视频"

## 物品大图（点击前显示的缩略图，可选）
@export var thumbnail: Texture2D

@onready var video_panel: CanvasLayer = $VideoPanel


# ==================== 初始化 ====================
func _ready() -> void:
	# 连接点击信号
	input_event.connect(_on_input_event)
	
	# 查找视频面板
	video_panel = _resolve_video_panel()
	
	if not video_panel:
		push_warning("警告: 找不到 VideoPanel，视频播放可能失败")
	
	# 检查视频文件是否存在
	if video_path and not ResourceLoader.exists(video_path):
		push_error("错误: 视频文件不存在 - " + video_path)


# ==================== 信号处理 ====================
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		print("\n=== ClickableVideo 被点击 ===")
		print("视频名称: ", video_name)
		print("视频路径: ", video_path)
		
		if not video_path:
			print("✗ 错误: 未设置视频路径!\n")
			return
		
		if not video_panel:
			video_panel = _resolve_video_panel()
		
		if video_panel:
			print("✓ 正在播放...\n")
			video_panel.play_video(video_path)
		else:
			print("✗ 错误: 找不到 VideoPanel!\n")


# ==================== 辅助函数 ====================
func _resolve_video_panel() -> CanvasLayer:
	"""向上查找场景中的 VideoPanel"""
	var current: Node = self
	while current:
		# 查找同级或父级中的 video_panel 变量
		var panel = current.get("video_panel")
		if panel is CanvasLayer:
			return panel
		
		# 查找 UILayer 下的 VideoPanel
		var panel_from_path = current.get_node_or_null("UILayer/VideoPanel")
		if panel_from_path is CanvasLayer:
			return panel_from_path
		
		current = current.get_parent()
	
	return null
