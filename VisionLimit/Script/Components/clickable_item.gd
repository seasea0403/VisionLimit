extends Area2D

# ==================== 配置参数 ====================
## 物品唯一ID
@export var item_id: String = "item_001"

## 物品名称
@export var item_name: String = "物品名称"

## 物品大图（点击后显示）
@export var detail_image: Texture2D

## 详情图缩放（可按物品单独设置）
@export var detail_image_scale: Vector2 = Vector2.ONE

## 详情图位置偏移（可按物品单独设置）
@export var detail_image_offset: Vector2 = Vector2.ZERO

## 物品描述（字幕）
@export var description: String = "这是物品的描述"

## 是否可以记录进发现册
@export var can_record: bool = false

## 记录册词条标题（留空则使用 item_name）
@export var record_entry_title: String = ""

## 记录册词条描述（留空则使用 description）
@export_multiline var record_entry_description: String = ""

## 第二条记录册词条标题
@export var record_entry_title_2: String = ""

## 第二条记录册词条描述
@export_multiline var record_entry_description_2: String = ""

## 说话人角色形象（切换说话人时改变）
@export var character_image: Texture2D

## 说话人角色形象缩放（调整以避免畸变，Vector2.ONE = 保持原样）
@export var character_scale: Vector2 = Vector2.ONE

## 说话人角色形象偏移（微调位置，不影响缩放锚点）
@export var character_offset: Vector2 = Vector2.ZERO

var item_detail: CanvasLayer


# ==================== 初始化 ====================
func _ready() -> void:
	# 进入场景时先尝试自动解析一次 ItemDetail
	item_detail = _resolve_item_detail()

	# 连接点击信号
	input_event.connect(_on_input_event)


# ==================== 信号处理 ====================
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		print("\n=== ClickableItem 被点击 ===")
		print("物品名称: ", item_name)
		print("物品ID: ", item_id)
		print("本地detail_image_scale值: ", detail_image_scale)

		# 兜底：若 _ready 时还没解析到，点击时再解析一次
		if not item_detail:
			item_detail = _resolve_item_detail()
		
		if item_detail:
			print("✓ 找到 ItemDetail，正在显示...\n")
			item_detail.show_detail(
				detail_image,
				description,
				item_name,
				can_record,
				item_id,
				detail_image_scale,
				detail_image_offset,
				record_entry_title,
				record_entry_description,
				record_entry_title_2,
				record_entry_description_2,
				character_image,
				character_scale,
				character_offset
			)
		else:
			print("✗ 错误：找不到 ItemDetail!")
			print("  原因: 未在父节点链中找到 Chapter1.item_detail 或 UILayer/ItemDetail\n")


func _resolve_item_detail() -> CanvasLayer:
	var current: Node = self
	while current:
		# 优先读取 Chapter1 脚本中暴露的 item_detail 变量
		var detail_from_var = current.get("item_detail")
		if detail_from_var is CanvasLayer:
			return detail_from_var

		# 兼容未挂脚本变量时，直接按节点结构查找
		var detail_from_path = current.get_node_or_null("UILayer/ItemDetail")
		if detail_from_path is CanvasLayer:
			return detail_from_path

		current = current.get_parent()

	return null


## 动态设置 ItemDetail 的方法（ZoomView 调用）
func set_item_detail(detail: CanvasLayer) -> void:
	item_detail = detail
