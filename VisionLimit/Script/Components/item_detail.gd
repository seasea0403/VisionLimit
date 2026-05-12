extends CanvasLayer

# ==================== 子节点引用 ====================
@onready var dark_background = $DarkBackground
@onready var image_display = $Control/ImageDisplay
@onready var title_label = $Control/TitleLabel
@onready var description_label = $Control/DescriptionLabel
@onready var record_button = $Control/RecordButton
@onready var close_button = $Control/CloseButton
@onready var text_sfx = $AudioStreamPlayer2D

# ==================== 状态变量 ====================
var current_item_id: String = ""
var can_record: bool = false

# ==================== 信号 ====================
signal item_recorded(item_id: String, description: String)


# ==================== 初始化 ====================
func _ready() -> void:
	_configure_image_display()

	# 连接按钮信号
	if dark_background:
		dark_background.gui_input.connect(_on_background_clicked)
	if close_button:
		close_button.pressed.connect(hide_detail)
	if record_button:
		record_button.pressed.connect(_on_record_button_pressed)
	
	# 初始化时隐藏
	hide()


func _configure_image_display() -> void:
	# 固定展示框，图片按比例居中，避免不同尺寸素材出现拉伸和错位
	if image_display:
		image_display.scale = Vector2.ONE
		image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


# ==================== 显示方法 ====================
func show_detail(texture: Texture2D, description: String, title: String, can_record_flag: bool = false, item_id: String = "", image_scale = Vector2.ONE, image_offset = Vector2.ZERO) -> void:
	"""
	显示物品详情
	参数：
	  - texture: 物品图片
	  - description: 物品描述
	  - title: 物品名称
	  - can_record_flag: 是否可以记录
	  - item_id: 物品ID
	  - image_scale: 详情图缩放（兼容旧数据中的 Nil）
	  - image_offset: 详情图位置偏移（兼容旧数据中的 Nil）
	"""
	_configure_image_display()
	image_display.texture = texture

	var safe_scale: Vector2 = Vector2.ONE
	if image_scale is Vector2:
		safe_scale = image_scale
	
	var safe_offset: Vector2 = Vector2.ZERO
	if image_offset is Vector2:
		safe_offset = image_offset
	
	print("显示物品: ", title)
	print("  接收缩放参数: ", image_scale)
	print("  接收位移参数: ", image_offset)
	print("  最终应用缩放: ", safe_scale)
	print("  最终应用位移: ", safe_offset)
	
	image_display.scale = Vector2(
		maxf(safe_scale.x, 0.01),
		maxf(safe_scale.y, 0.01)
	)
	image_display.position = safe_offset

	description_label.text = description
	title_label.text = title
	current_item_id = item_id
	can_record = can_record_flag
	
	# 如果不可记录，隐藏记录按钮
	record_button.visible = can_record_flag
	show()
	text_sfx.play()


# ==================== 隐藏方法 ====================
func hide_detail() -> void:
	"""
	隐藏物品详情
	"""
	hide()


# ==================== 事件处理 ====================
func _on_background_clicked(event: InputEvent) -> void:
	"""
	点击黑色背景关闭
	"""
	if event is InputEventMouseButton and event.pressed:
		hide_detail()


func _on_record_button_pressed() -> void:
	"""
	点击记录按钮，添加到发现册
	"""
	if can_record:
		# 发射信号
		item_recorded.emit(current_item_id, description_label.text)
		
		# 调用 GameState 记录，待实现
