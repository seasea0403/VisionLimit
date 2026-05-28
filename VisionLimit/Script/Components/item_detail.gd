extends Control

# ==================== 子节点引用 ====================
@onready var dark_background = $DarkBackground
@onready var image_display = $Control/ImageDisplay
@onready var title_label = $Control/TitleLabel
@onready var description_label = $Control/DescriptionLabel
@onready var record_button = $Control/record/TextureButton
@onready var character_display = $Control/Character
@onready var text_sfx = $click
@onready var prev_button = $Control/PrevButton/TextureButton
@onready var next_button = $Control/LaterButton/TextureButton
@onready var next_button_label = $Control/LaterButton/TextureButton/Label
@onready var page_indicator = $Control/PageIndicator
@onready var back_button = $Control/back/TextureButton

# ==================== 状态变量 ====================
var current_item_id: String = ""
var can_record: bool = false
var _image_base_position: Vector2 = Vector2.ZERO
var _character_base_position: Vector2 = Vector2.ZERO
var _character_base_scale: Vector2 = Vector2.ONE
var current_title: String = ""
var current_record_title: String = ""
var current_record_description: String = ""
var current_record_title_2: String = ""
var current_record_description_2: String = ""

# ==================== 多页状态 ====================
var _pages: Array[Dictionary] = []
var _current_page: int = 0
# 缓存 chapter 节点引用，避免每次 show 时重复向上遍历树
var _chapter_cache: Node = null

# ==================== 信号 ====================
signal item_recorded(item_id: String, entry_title: String, entry_description: String, entry_title_2: String, entry_description_2: String)
signal panel_closed
## 详情面板打开时发出，携带当前 item_id
signal detail_opened(item_id: String)


# ==================== 角色立绘按图覆盖表（可在 Inspector 中配置）====================
## 在 Inspector 中加条目，每个 CharacterOverride 可拖入一张立绘并指定对应的 scale / offset。
## 未出现在表中的图都会使用 Character 节点原本的位置与缩放。
@export var character_overrides: Array[CharacterOverride] = []


# ==================== 初始化 ====================
func _ready() -> void:
	_configure_image_display()
	if image_display:
		_image_base_position = image_display.position
	if character_display:
		_character_base_position = character_display.position
		_character_base_scale = character_display.scale

	# 连接按钮信号
	if dark_background:
		# 设置为 IGNORE，使背景不消耗鼠标事件，避免遮挡 HUD 返回按钮。
		# 点击背景关闭改由 _unhandled_input 处理。
		dark_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if record_button:
		record_button.pressed.connect(_on_record_button_pressed)
	if prev_button:
		prev_button.pressed.connect(_on_prev_pressed)
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	if back_button:
		back_button.pressed.connect(close_detail)
	
	# 初始化时隐藏
	hide()
	# 注册到分组，便于其他节点动态查找
	add_to_group("item_detail")
	# 延迟执行一次布局预热，消除首次 show() 时的 layout 重算卡顿
	call_deferred("_prewarm_layout")


func _configure_image_display() -> void:
	# 固定展示框，图片按比例居中，避免不同尺寸素材出现拉伸和错位
	if image_display:
		image_display.scale = Vector2.ONE
		# 忽略纹理原始像素尺寸，始终按 ImageDisplay 的矩形框来适配
		image_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _apply_character_overrides(tex: Texture2D) -> void:
	"""根据传入的角色图，在 character_overrides 数组中查找差异参数；
	找不到就把 Character 节点恢复到场景里原始的 position 与 scale。"""
	if not character_display:
		return
	var scale_mul: Vector2 = Vector2.ONE
	var offset: Vector2 = Vector2.ZERO
	if tex:
		for entry in character_overrides:
			if entry and entry.texture == tex:
				scale_mul = entry.scale
				offset = entry.offset
				break
	character_display.scale = _character_base_scale * scale_mul
	character_display.position = _character_base_position + offset


# ==================== 显示方法 ====================
func show_detail(texture: Texture2D, description: String, title: String, can_record_flag: bool = false, item_id: String = "", image_scale = Vector2.ONE, image_offset = Vector2.ZERO, record_title = "", record_description = "", record_title_2 = "", record_description_2 = "", character_image: Texture2D = null) -> void:
	"""单页快捷方式，内部转为单元素列表交给多页系统处理"""
	show_detail_group([{
		"texture": texture,
		"description": description,
		"title": title,
		"can_record": can_record_flag,
		"item_id": item_id,
		"image_scale": image_scale,
		"image_offset": image_offset,
		"record_title": record_title,
		"record_description": record_description,
		"record_title_2": record_title_2,
		"record_description_2": record_description_2,
		"character_image": character_image,
	}])


func show_detail_group(pages: Array[Dictionary]) -> void:
	"""显示多页物品详情，pages 中每个 Dictionary 对应一页内容"""
	if pages.is_empty():
		return
	_pages = pages
	_apply_page(0)
	# 确保预热期间 modulate 被重置为完全可见
	modulate.a = 1.0
	show()
	text_sfx.play()
	var chapter := _find_chapter()
	if chapter and chapter.has_method("register_panel_open"):
		chapter.register_panel_open(self)
	# 通知监听者面板已打开（用于按需显示动作按钮等）
	detail_opened.emit(current_item_id)


func _apply_page(idx: int) -> void:
	"""将第 idx 页的数据渲染到界面"""
	if _pages.is_empty() or idx < 0 or idx >= _pages.size():
		return
	_current_page = idx
	var p: Dictionary = _pages[idx]

	var texture = p.get("texture", null)
	var description: String = p.get("description", "")
	var title: String = p.get("title", "")
	var can_record_flag: bool = p.get("can_record", false)
	var item_id: String = p.get("item_id", "")
	var image_scale = p.get("image_scale", Vector2.ONE)
	var image_offset = p.get("image_offset", Vector2.ZERO)
	var record_title = p.get("record_title", "")
	var record_description = p.get("record_description", "")
	var record_title_2 = p.get("record_title_2", "")
	var record_description_2 = p.get("record_description_2", "")
	var character_image = p.get("character_image", null)

	image_display.texture = texture

	if character_display:
		if character_image:
			character_display.texture = character_image
			_apply_character_overrides(character_image)
			character_display.visible = true
		else:
			character_display.texture = null
			character_display.visible = false

	var safe_scale: Vector2 = image_scale if image_scale is Vector2 else Vector2.ONE
	var safe_offset: Vector2 = image_offset if image_offset is Vector2 else Vector2.ZERO
	image_display.scale = Vector2(maxf(safe_scale.x, 0.01), maxf(safe_scale.y, 0.01))
	image_display.position = _image_base_position + safe_offset

	description_label.text = description
	title_label.text = title
	current_item_id = item_id
	current_title = title
	can_record = can_record_flag

	current_record_title = record_title.strip_edges() if record_title is String else ""
	if current_record_title.is_empty():
		current_record_title = title
	current_record_description = record_description.strip_edges() if record_description is String else ""
	if current_record_description.is_empty():
		current_record_description = description
	current_record_title_2 = record_title_2.strip_edges() if record_title_2 is String else ""
	current_record_description_2 = record_description_2.strip_edges() if record_description_2 is String else ""

	record_button.visible = can_record_flag
	_update_nav_buttons()


func set_action_button(visible_state: bool, label_text: String = "尝试") -> void:
	"""显示或隐藏 LaterButton 的动作模式（历史兼容接口）"""
	if next_button_label:
		next_button_label.text = label_text if visible_state else ""
	_update_nav_buttons()


func _update_nav_buttons() -> void:
	"""根据页数更新翻页按钮和页码指示器的可见性与状态"""
	var multi: bool = _pages.size() > 1
	if prev_button:
		prev_button.visible = multi
		prev_button.disabled = (_current_page == 0)
	if next_button:
		next_button.visible = multi
		next_button.disabled = (_current_page == _pages.size() - 1)
	if page_indicator:
		page_indicator.visible = multi
		if multi:
			page_indicator.text = "%d / %d" % [_current_page + 1, _pages.size()]


func _find_chapter() -> Node:
	if _chapter_cache and is_instance_valid(_chapter_cache):
		return _chapter_cache
	var node := get_parent()
	while node:
		if node.has_method("register_panel_open"):
			_chapter_cache = node
			return node
		node = node.get_parent()
	return null


# ==================== 预热（消除首次显示卡顿）====================
func _prewarm_layout() -> void:
	"""在场景启动后做一次不可见的 show/hide，让 Godot 提前完成 layout 计算缓存。"""
	modulate.a = 0.0
	show()
	await get_tree().process_frame
	hide()
	modulate.a = 1.0


func prewarm_textures(textures: Array) -> void:
	"""预热场景内所有可点击物品的纹理 GPU 上传，消除首次点击的卡顿。
	由 chapter.gd 在场景就绪后通过 call_deferred 调用。"""
	if not image_display or textures.is_empty():
		return
	var prev_modulate_a := modulate.a
	modulate.a = 0.0
	show()
	for tex in textures:
		if not is_inside_tree():
			break
		if tex is Texture2D:
			image_display.texture = tex
			await get_tree().process_frame
	if is_inside_tree() and not visible:
		pass  # show_detail_group 已打开面板，无需再 hide
	if is_inside_tree() and modulate.a == 0.0:
		# 仍处于预热状态（未被 show_detail_group 中断），恢复隐藏
		image_display.texture = null
		hide()
		modulate.a = prev_modulate_a

# ==================== 面板打开/关闭接口 ====================
func open_detail() -> void:
	"""打开物品详情面板"""
	show()


func set_dark_background_visible(value: bool) -> void:
	"""控制暗色背景显示（ZoomView 唤出时可隐藏）"""
	if dark_background:
		dark_background.visible = value


func close_detail() -> void:
	# 恢复暗色背景（下次正常打开时确保可见）
	if dark_background:
		dark_background.visible = true
	# 隐藏面板本身
	hide()

	# 清理多页状态
	_pages.clear()
	_current_page = 0
	_update_nav_buttons()

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

	# 通知监听者面板已关闭
	panel_closed.emit()


# ==================== 翻页处理 ====================
func _on_prev_pressed() -> void:
	if _current_page > 0:
		_apply_page(_current_page - 1)


func _on_next_pressed() -> void:
	if _current_page < _pages.size() - 1:
		_apply_page(_current_page + 1)


# ==================== 输入处理 ====================
func _unhandled_input(event: InputEvent) -> void:
	"""ItemDetail 可见时，点击内容区域外部则关闭面板（取代 DarkBackground 的 gui_input）"""
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed:
		var content_panel := get_node_or_null("Control")
		if content_panel and content_panel.visible:
			if not content_panel.get_global_rect().has_point(event.position):
				get_viewport().set_input_as_handled()
				close_detail()


func _on_background_clicked(event: InputEvent) -> void:
	"""
	点击黑色背景关闭
	"""
	if event is InputEventMouseButton and event.pressed:
		close_detail()


func _on_record_button_pressed() -> void:
	"""
	点击记录按钮，添加到发现册并加入物品收藏面板
	"""
	if can_record:
		# 发射信号（RecordPanel 用）
		item_recorded.emit(current_item_id, current_record_title, current_record_description, current_record_title_2, current_record_description_2)

		# 存入 SumPanel 物品收藏仓库
		var thumb: Texture2D = null
		if _pages.size() > 0:
			thumb = _pages[_current_page].get("texture", null)
		var desc: String = current_record_description if not current_record_description.strip_edges().is_empty() \
			else (_pages[_current_page].get("description", "") if _pages.size() > 0 else "")
		GameStateManager.add_inventory_item(current_item_id, current_title, desc, thumb)
