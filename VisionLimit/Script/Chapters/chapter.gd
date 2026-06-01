extends Node2D

@onready var item_detail = $UILayer/ItemDetail
@onready var zoom_views_root = $ZoomViews
@onready var clickable_areas = $ZoomViews.get_children()
@onready var ui_layer = $UILayer
@onready var hud_back_button = $UILayer/HudPanel/back/TextureButton
@onready var hud_book_button = get_node_or_null("UILayer/HudPanel/book/TextureButton")
@onready var hud_items_button = $UILayer/HudPanel/items/TextureButton
@onready var hud_inference_button = $UILayer/HudPanel/inference/TextureButton

var record_panel: Control
var sum_panel: Control
var inference_panel: Control
# 使用栈管理嵌套的面板，最上层的面板在栈顶
var _panel_stack: Array[Node] = []
var stop_panel: Node = null

## 当前章节编号（由子类在 super._ready() 前赋值）
var chapter_number: int = 0
## 多场景章节的后续场景（如 chapter_3_2、chapter_7_2_A/C）设为 true，
## 以避免进入时清空本章已收集物品
var is_chapter_continuation: bool = false


func _ready():
	# 向 GameStateManager 注册当前章节编号；若为多场景章节的续集则不清空物品
	if chapter_number > 0:
		GameStateManager.set_current_chapter(chapter_number)
		if not is_chapter_continuation:
			GameStateManager.reset_chapter_items(chapter_number)
	# 进入任意章节时停止跨场景全局音乐（结局音乐等），让本章节 SceneBgm 主导
	GameStateManager.stop_global_music()
	zoom_views_root.show()
	for area in clickable_areas:
		area.show()
		for child in area.get_children():
			if child.has_method("hide_view"):
				child.hide_view()

	item_detail.hide()
	_setup_record_panel()
	_setup_stop_panel()
	_setup_sum_panel()
	_setup_inference_panel()

	if item_detail and item_detail.has_signal("item_recorded"):
		if not item_detail.item_recorded.is_connected(_on_item_recorded):
			item_detail.item_recorded.connect(_on_item_recorded)

	if hud_back_button:
		hud_back_button.pressed.connect(_on_hud_back_pressed)
	else:
		push_warning("chapter.gd: 找不到 HUD back 按钮，路径 $UILayer/HudPanel/back/TextureButton")

	if hud_book_button:
		hud_book_button.pressed.connect(_on_hud_book_pressed)
	else:
		push_warning("chapter.gd: 找不到 HUD book 按钮，路径 $UILayer/HudPanel/book/TextureButton")

	if hud_items_button:
		hud_items_button.pressed.connect(_on_hud_items_pressed)
	else:
		push_warning("chapter.gd: 找不到 HUD items 按钮，路径 $UILayer/HudPanel/items/TextureButton")

	if hud_inference_button:
		hud_inference_button.pressed.connect(_on_hud_inference_pressed)
	else:
		push_warning("chapter.gd: 找不到 HUD inference 按钮，路径 $UILayer/HudPanel/inference/TextureButton")

	# 场景就绪后延迟一帧，预热所有可点击物品的纹理，消除首次点击的 GPU 上传延迟
	call_deferred("_prewarm_item_textures")


# ==================== 面板追踪 ====================
func register_panel_open(panel: Node) -> void:
	"""面板打开时调用此方法，将其加入栈"""
	if panel and not panel in _panel_stack:
		_panel_stack.append(panel)


func _unregister_panel(panel: Node) -> void:
	"""面板关闭时调用此方法，将其从栈中移除"""
	if panel in _panel_stack:
		_panel_stack.erase(panel)


# ==================== HUD 按钮处理 ====================
func _on_hud_back_pressed() -> void:
	# 从栈顶开始，找第一个可见的面板并关闭它
	while _panel_stack.size() > 0:
		var panel: Node = _panel_stack.pop_back()
		if not is_instance_valid(panel):
			continue
		
		if panel.visible:
			if panel.has_method("close_detail"):
				panel.close_detail()
			elif panel.has_method("hide_view"):
				panel.hide_view()
			elif panel.has_method("close_panel"):
				panel.close_panel()
			else:
				panel.hide()
			return

	# 兜底：逐层查找可见面板（处理不在栈中的面板）
	if item_detail and item_detail.visible:
		item_detail.close_detail()
		return
	for area in zoom_views_root.get_children():
		for child in area.get_children():
			if child.has_method("hide_view") and child.visible:
				child.hide_view()
				return

	# 兜底2：没有任何面板可关闭，切换暂停菜单状态
	if stop_panel:
		if stop_panel.visible:
			stop_panel.call("close_panel")
		else:
			stop_panel.call("open_panel")


func _on_hud_book_pressed() -> void:
	if record_panel and record_panel.has_method("open_panel"):
		record_panel.open_panel()
		register_panel_open(record_panel)


func _on_hud_items_pressed() -> void:
	if sum_panel and sum_panel.has_method("open_panel"):
		sum_panel.open_panel()
		register_panel_open(sum_panel)


func _on_hud_inference_pressed() -> void:
	if inference_panel and inference_panel.has_method("open_panel"):
		inference_panel.open_panel()
		register_panel_open(inference_panel)


func _setup_stop_panel() -> void:
	stop_panel = find_child("StopPanel", true, false)
	if not stop_panel:
		var scene: PackedScene = load("res://Game/UI/StopPanel.tscn")
		if scene:
			stop_panel = scene.instantiate()
			stop_panel.name = "StopPanel"
			add_child(stop_panel)


func _setup_record_panel() -> void:
	record_panel = ui_layer.find_child("RecordPanel", true, false) as Control
	if record_panel:
		return
	var record_panel_scene := load("res://Game/UI/RecordPanel/RecordPanel.tscn")
	if not record_panel_scene:
		return
	record_panel = record_panel_scene.instantiate() as Control
	if not record_panel:
		return
	record_panel.name = "RecordPanel"
	ui_layer.add_child(record_panel)


func _setup_sum_panel() -> void:
	sum_panel = ui_layer.find_child("SumPanel", true, false) as Control
	if sum_panel:
		return
	var sum_panel_scene := load("res://Game/UI/SumPanel/SumPanel.tscn")
	if not sum_panel_scene:
		return
	sum_panel = sum_panel_scene.instantiate() as Control
	if not sum_panel:
		return
	sum_panel.name = "SumPanel"
	ui_layer.add_child(sum_panel)


func _setup_inference_panel() -> void:
	inference_panel = ui_layer.find_child("InferencePanel", true, false) as Control
	if inference_panel:
		return
	var scene := load("res://Game/UI/InferencePanel/InferencePanel.tscn")
	if not scene:
		return
	inference_panel = scene.instantiate() as Control
	if not inference_panel:
		return
	inference_panel.name = "InferencePanel"
	ui_layer.add_child(inference_panel)


func _on_item_recorded(item_id: String, entry_title: String, entry_description: String, entry_title_2: String, entry_description_2: String) -> void:
	# 同步到旧版 RecordPanel（如场景内仍保留）
	if record_panel and record_panel.has_method("add_or_update_entry"):
		record_panel.call("add_or_update_entry", item_id, entry_title, entry_description)
		if not entry_title_2.strip_edges().is_empty() or not entry_description_2.strip_edges().is_empty():
			record_panel.call("add_or_update_entry", item_id + "_b", entry_title_2, entry_description_2)
	# 同步到 SumPanel 的记录页
	if sum_panel and sum_panel.has_method("add_record_entry"):
		sum_panel.call("add_record_entry", item_id, entry_title, entry_description)
		if not entry_title_2.strip_edges().is_empty() or not entry_description_2.strip_edges().is_empty():
			sum_panel.call("add_record_entry", item_id + "_b", entry_title_2, entry_description_2)


# ==================== 音效工具 ====================
func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()


# ==================== 纹理预热 ====================
func _prewarm_item_textures() -> void:
	"""收集场景内所有 ClickableItem 的纹理，交给 ItemDetail 做 GPU 预热。
	在 _ready() 通过 call_deferred 调用，确保子节点已全部就绪。"""
	if not item_detail:
		return
	var textures: Array = []
	for node in get_tree().get_nodes_in_group("clickable_items"):
		# 只收集属于本场景的物品（过滤其他场景残留）
		if not node.is_inside_tree():
			continue
		var tex = node.get("detail_image")
		if tex is Texture2D:
			textures.append(tex)
		var char_tex = node.get("character_image")
		if char_tex is Texture2D:
			textures.append(char_tex)
	if textures.size() > 0 and item_detail.has_method("prewarm_textures"):
		item_detail.prewarm_textures(textures)
