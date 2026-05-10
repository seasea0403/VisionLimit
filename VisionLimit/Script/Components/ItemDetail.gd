extends CanvasLayer

# ==================== 子节点引用 ====================
@onready var dark_background = $DarkBackground
@onready var image_display = $Panel/VBoxContainer/ImageDisplay
@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var description_label = $Panel/VBoxContainer/DescriptionLabel
@onready var record_button = $Panel/VBoxContainer/ButtonContainer/RecordButton
@onready var close_button = $Panel/VBoxContainer/ButtonContainer/CloseButton

# ==================== 状态变量 ====================
var current_item_id: String = ""
var can_record: bool = false

# ==================== 信号 ====================
signal item_recorded(item_id: String, description: String)


# ==================== 初始化 ====================
func _ready() -> void:
	# 连接按钮信号
	dark_background.gui_input.connect(_on_background_clicked)
	close_button.pressed.connect(hide_detail)
	record_button.pressed.connect(_on_record_button_pressed)
	
	# 初始化时隐藏
	visible = false


# ==================== 显示方法 ====================
func show_detail(texture: Texture2D, description: String, item_id: String, can_record_flag: bool) -> void:
	"""
	显示物品详情
	"""
	image_display.texture = texture
	description_label.text = description
	current_item_id = item_id
	can_record = can_record_flag
	
	# 如果不可记录，隐藏记录按钮
	record_button.visible = can_record_flag
	
	visible = true


# ==================== 隐藏方法 ====================
func hide_detail() -> void:
	"""
	隐藏物品详情
	"""
	visible = false


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
		
		# 调用 GameState 记录
		#GameState.add_discovery(description_label.text)
		
		print("已记录: %s" % current_item_id)
		hide_detail()
