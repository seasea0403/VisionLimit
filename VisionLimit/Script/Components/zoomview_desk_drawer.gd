extends "res://Script/Components/zoomview.gd"

# ==================== 状态 ====================
## 抽屉是否已解锁（钥匙已成功使用）
var unlocked: bool = false

## 钥匙解锁面板（运行时实例化后挂入 UILayer）
var _key_panel: Control = null


# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()

	# 解锁前禁止直接点击 photo，必须先通过钥匙解锁
	var photo := get_node_or_null("Items/photo") as Area2D
	if photo:
		photo.input_pickable = false

	# 实例化 DrawerKeyPanel 并挂入 UILayer
	var panel_scene: PackedScene = load("res://Game/UI/DrawerKeyPanel/DrawerKeyPanel.tscn")
	if not panel_scene:
		push_error("zoomview_desk_drawer.gd: 找不到 DrawerKeyPanel.tscn")
		return

	_key_panel = panel_scene.instantiate() as Control
	_key_panel.name = "DrawerKeyPanel"

	var chapter := _find_chapter()
	if chapter:
		var ui_layer: Node = chapter.get_node_or_null("UILayer")
		if ui_layer:
			ui_layer.add_child(_key_panel)
		else:
			chapter.add_child(_key_panel)
	else:
		add_child(_key_panel)

	_key_panel.unlock_success.connect(_on_drawer_unlocked)


# ==================== ZoomView 打开逻辑（覆盖基类）====================
func show_view() -> void:
	if unlocked:
		# 已解锁：直接展示背景 + 物品详情
		show()
		_disable_other_area_inputs()
		_show_photo_detail()
	else:
		# 未解锁：正常显示 ZoomView 背景（锁住的抽屉近景），同时打开钥匙面板
		super.show_view()
		if is_instance_valid(_key_panel):
			_key_panel.open_panel()
			var chapter := _find_chapter()
			if chapter and chapter.has_method("register_panel_open"):
				chapter.register_panel_open(_key_panel)


# ==================== 解锁回调 ====================
func _on_drawer_unlocked() -> void:
	unlocked = true
	# 记录跨章节标记：第五章据此决定是否播放路上对话
	GameStateManager.set_record("ch4_got_photo_19", "1")

	# 从物品栏移除钥匙
	if is_instance_valid(_key_panel):
		var items: Dictionary = GameStateManager.get_inventory_items()
		items.erase(_key_panel.key_item_id)

	# 关闭面板并从栈移除
	if is_instance_valid(_key_panel):
		_key_panel.close_panel()
		var chapter := _find_chapter()
		if chapter and chapter.has_method("_unregister_panel"):
			chapter._unregister_panel(_key_panel)

	# 恢复 photo 的可点击性（日后再打开 zoomview 可直接点击）
	var photo := get_node_or_null("Items/photo") as Area2D
	if photo:
		photo.input_pickable = true

	# 展示照片详情
	_show_photo_detail()


# ==================== 展示照片 ItemDetail ====================
func _show_photo_detail() -> void:
	var photo := get_node_or_null("Items/photo")
	if not is_instance_valid(photo):
		push_warning("zoomview_desk_drawer.gd: 找不到 Items/photo 节点")
		return

	var chapter := _find_chapter()
	if not chapter:
		return

	var item_detail = chapter.get("item_detail")
	if not item_detail or not item_detail.has_method("show_detail"):
		return

	item_detail.show_detail(
		photo.detail_image,
		photo.description,
		photo.item_name,
		photo.can_record,
		photo.item_id,
		photo.detail_image_scale,
		photo.detail_image_offset,
		photo.record_entry_title,
		photo.record_entry_description,
		photo.record_entry_title_2,
		photo.record_entry_description_2,
		photo.character_image
	)
