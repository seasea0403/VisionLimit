extends CanvasLayer

# ==================== 子节点引用 ====================
@onready var dark_background = $DarkBackground
@onready var image_display = $Control/ImageDisplay
@onready var title_label = $Control/TitleLabel
@onready var description_label = $Control/DescriptionLabel
@onready var record_button = $Control/record/TextureButton
@onready var text_sfx = $click

# ==================== 状态变量 ====================
var current_item_id: String = ""
var can_record: bool = false
var _image_base_position: Vector2 = Vector2.ZERO
var current_title: String = ""
var current_record_title: String = ""
var current_record_description: String = ""
var current_record_title_2: String = ""
var current_record_description_2: String = ""

# ==================== 信号 ====================
signal item_recorded(item_id: String, entry_title: String, entry_description: String, entry_title_2: String, entry_description_2: String)


# ==================== 初始化 ====================
func _ready() -> void:
	_configure_image_display()
	if image_display:
		_image_base_position = image_display.position

	# 连接按钮信号
	if dark_background:
		dark_background.gui_input.connect(_on_background_clicked)
	if record_button:
		record_button.pressed.connect(_on_record_button_pressed)
	
	# 初始化时隐藏
	hide()


func _configure_image_display() -> void:
	# 固定展示框，图片按比例居中，避免不同尺寸素材出现拉伸和错位
	if image_display:
		image_display.scale = Vector2.ONE
		# 忽略纹理原始像素尺寸，始终按 ImageDisplay 的矩形框来适配
		image_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


# ==================== 显示方法 ====================
func show_detail(texture: Texture2D, description: String, title: String, can_record_flag: bool = false, item_id: String = "", image_scale = Vector2.ONE, image_offset = Vector2.ZERO, record_title = "", record_description = "", record_title_2 = "", record_description_2 = "") -> void:
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
	image_display.position = _image_base_position + safe_offset

	description_label.text = description
	title_label.text = title
	current_item_id = item_id
	current_title = title
	can_record = can_record_flag

	current_record_title = ""
	if record_title is String:
		current_record_title = record_title.strip_edges()
	if current_record_title.is_empty():
		current_record_title = title

	current_record_description = ""
	if record_description is String:
		current_record_description = record_description.strip_edges()
	if current_record_description.is_empty():
		current_record_description = description

	current_record_title_2 = ""
	if record_title_2 is String:
		current_record_title_2 = record_title_2.strip_edges()

	current_record_description_2 = ""
	if record_description_2 is String:
		current_record_description_2 = record_description_2.strip_edges()
	
	# 如果不可记录，隐藏记录按钮
	record_button.visible = can_record_flag
	show()
	text_sfx.play()	# 通知 chapter 追踪当前打开的面板
	var chapter := _find_chapter()
	if chapter and chapter.has_method("register_panel_open"):
		chapter.register_panel_open(self)


func _find_chapter() -> Node:
	var node := get_parent()
	while node:
		if node.has_method("register_panel_open"):
			return node
		node = node.get_parent()
	return null

# ==================== 面板打开/关闭接口 ====================
func open_detail() -> void:
	"""打开物品详情面板"""
	show()


func close_detail() -> void:
	"""
	隐藏物品详情面板，清理状态
	"""
	# 隐藏面板本身
	hide()
	
	# 清理状态
	current_item_id = ""
	current_title = ""
	can_record = false
	current_record_title = ""
	current_record_description = ""
	current_record_title_2 = ""
	current_record_description_2 = ""
	
	# 重置图片显示到默认状态
	if image_display:
		image_display.scale = Vector2.ONE
		image_display.position = _image_base_position


# ==================== 事件处理 ====================
func _on_background_clicked(event: InputEvent) -> void:
	"""
	点击黑色背景关闭
	"""
	if event is InputEventMouseButton and event.pressed:
		close_detail()


func _on_record_button_pressed() -> void:
	"""
	点击记录按钮，添加到发现册
	"""
	if can_record:
		# 发射信号
		item_recorded.emit(current_item_id, current_record_title, current_record_description, current_record_title_2, current_record_description_2)
		
		# 调用 GameState 记录，待实现
