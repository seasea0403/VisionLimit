extends Control

# ==================== 子节点引用 ====================
@onready var dark_background = $DarkBackground
@onready var image_display = $Control/ImageDisplay
@onready var title_label = $Control/TitleLabel
@onready var content_node: Node2D = $Control/content
@onready var description_label = $Control/content/DescriptionLabel
@onready var record_button = get_node_or_null("Control/record/TextureButton")
@onready var character_display = $Control/content/Character
@onready var text_sfx = $click
@onready var prev_button = $Control/PrevButton/TextureButton
@onready var next_button = $Control/LaterButton/TextureButton
@onready var next_button_label = $Control/LaterButton/TextureButton/Label
@onready var page_indicator = $Control/PageIndicator
@onready var back_button = $Control/back/TextureButton
@onready var frame_synthesis_panel: Control = $Control/FrameSynthesisPanel

# ==================== 合成解谜配置 ====================
## 需要触发合成解谜模式的物品 ID 列表；列表非空且当前物品 ID 在其中时激活合成栏
@export var synthesis_item_ids: Array[String] = []
## 合成完成后在底部显示的文字内容
@export_multiline var synthesis_complete_text: String = ""
## 合成完成后加入物品栏的物品 ID（留空则不加入）
@export var synthesis_result_id: String = ""
## 合成完成后加入物品栏的物品名称
@export var synthesis_result_title: String = ""
## 合成完成后加入物品栏的缩略图
@export var synthesis_result_texture: Texture2D = null

# ==================== 状态变量 ====================
var current_item_id: String = ""
var can_record: bool = false
var _image_base_position: Vector2 = Vector2.ZERO
var _synthesis_active: bool = false   # 当前是否处于合成模式
var _synthesis_done: bool = false     # 合成是否已完成（跨开关面板保留）
## 在此列表中的 item_id 将跳过自动入库（由使用方按需配置）
var no_auto_inventory_ids: Array[String] = []
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
	# 详情是模态界面：空白区域也必须命中自身，而非背后的浏览器按钮。
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_configure_image_display()
	if image_display:
		_image_base_position = image_display.position
	if character_display:
		_character_base_position = character_display.position
		_character_base_scale = character_display.scale
		# 确保角色立绘始终渲染在描述文字和背景图上方
		character_display.z_index = 1

	# 让整个内容容器对鼠标事件透传，使 Area2D 物品在面板开启时仍可点击。
	# 按钮等子节点自身仍是 MOUSE_FILTER_STOP，不影响 UI 交互。
	$Control.mouse_filter = Control.MOUSE_FILTER_PASS

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
		back_button.get_parent().hide()
	
	# 连接合成面板信号
	if frame_synthesis_panel and frame_synthesis_panel.has_signal("synthesis_complete"):
		frame_synthesis_panel.synthesis_complete.connect(_on_synthesis_complete)

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
	# Godot 的 z_index 只改变绘制顺序，不改变 GUI 命中顺序。
	# 同时置于兄弟节点末尾，确保遮罩和详情先于桌面接收鼠标事件。
	var parent := get_parent()
	if parent:
		parent.move_child(self, parent.get_child_count() - 1)
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

	if record_button:
		record_button.visible = can_record_flag
	_update_nav_buttons()
	# 自动入库 + 自动解锁词条（无需手动点击记录按鈕）
	_auto_record(p)
	# 检测是否需要激活合成解谜模式
	_try_activate_synthesis()
	if back_button:
		back_button.get_parent().visible = _synthesis_active and not _synthesis_done


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

	# 关闭合成面板
	if _synthesis_active:
		_synthesis_active = false
		if frame_synthesis_panel:
			frame_synthesis_panel.close_panel()
		if content_node:
			content_node.show()

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
func _input(event: InputEvent) -> void:
	# 在 GUI/场景物件处理前消费关闭点击，避免同一次点击又打开背后的物品。
	if not is_visible_in_tree():
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	# 未完成的照片合成仍需拖放；其原有返回入口保留。
	if _synthesis_active and not _synthesis_done:
		return
	var hovered := get_viewport().gui_get_hovered_control()
	# 翻页、记录、滚动等真实操作优先，覆盖在详情之上的其他面板也不受影响。
	var target: Node = hovered
	while target:
		if target is BaseButton or target is Range or target is LineEdit or target is TextEdit:
			return
		target = target.get_parent()
	if hovered and hovered != self and not is_ancestor_of(hovered):
		return
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


func _auto_record(page: Dictionary) -> void:
	"""_apply_page 末尾调用：自动入库 + 自动解锁词条，无需手动点击记录按钮"""
	if current_item_id.is_empty():
		return

	var texture: Texture2D = page.get("texture", null)
	# 合成解谜物品在合成完成前不加入物品栏
	var is_pending_synthesis: bool = \
		not synthesis_item_ids.is_empty() and (current_item_id in synthesis_item_ids) and not _synthesis_done
	# 有图片且不是待合成物品，且不在阻止列表中 → 加入物品收藏
	if texture != null and not is_pending_synthesis and current_item_id not in no_auto_inventory_ids:
		var inv_desc: String = (page.get("description", "") as String)
		GameStateManager.add_inventory_item(current_item_id, current_title, inv_desc, texture)

	# 词条标题 / 描述原始值（不做 fallback）
	var orig_rec_title: String = (page.get("record_title", "") as String).strip_edges()
	var orig_rec_desc: String  = (page.get("record_description", "") as String).strip_edges()
	var orig_rec_title_2: String = (page.get("record_title_2", "") as String).strip_edges()
	var orig_rec_desc_2: String  = (page.get("record_description_2", "") as String).strip_edges()

	# 任一非空 → 解锁词条；标题为空时以物品名代替
	if not orig_rec_title.is_empty() or not orig_rec_desc.is_empty():
		var eff_title: String = orig_rec_title if not orig_rec_title.is_empty() else current_title
		item_recorded.emit(current_item_id, eff_title, orig_rec_desc, orig_rec_title_2, orig_rec_desc_2)


# ==================== 合成解谜模式 ====================
func _try_activate_synthesis() -> void:
	"""根据 current_item_id 决定是否激活合成解谜模式"""
	if not frame_synthesis_panel:
		return
	var should_be_synthesis: bool = \
		not synthesis_item_ids.is_empty() and (current_item_id in synthesis_item_ids)
	if should_be_synthesis:
		_synthesis_active = true
		if _synthesis_done:
			# ── 完成态：主图换成合成结果图，显示描述，合成面板保持关闭（无法再交互）
			if synthesis_result_texture:
				image_display.texture = synthesis_result_texture
			description_label.text = synthesis_complete_text
			content_node.show()
			if frame_synthesis_panel.visible:
				frame_synthesis_panel.close_panel()
		else:
			# ── 未完成：隐藏文字区，打开合成面板（每次刷新底栏）
			content_node.hide()
			frame_synthesis_panel.open_panel()
	else:
		# 非合成物品：无论之前状态如何都恢复 content 显示
		if _synthesis_active:
			_synthesis_active = false
			frame_synthesis_panel.close_panel()
		content_node.show()


func _on_synthesis_complete() -> void:
	"""两张照片均摆放完成时触发，显示完整文字内容并加入物品栏"""
	_synthesis_done = true
	if back_button:
		back_button.get_parent().hide()
	description_label.text = synthesis_complete_text
	content_node.show()
	# 锁定合成面板，禁止再次拖拽
	if frame_synthesis_panel:
		frame_synthesis_panel.lock()
	# 将合成结果加入物品栏
	if not synthesis_result_id.is_empty():
		GameStateManager.add_inventory_item(
			synthesis_result_id,
			synthesis_result_title,
			synthesis_complete_text,
			synthesis_result_texture
		)
