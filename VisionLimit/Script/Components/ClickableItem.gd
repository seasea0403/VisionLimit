extends Area2D

# ==================== 配置参数 ====================
## 物品唯一ID
@export var item_id: String = "item_001"

## 物品名称
@export var item_name: String = "物品名称"

## 物品大图（点击后显示）
@export var detail_image: Texture2D

## 物品描述（字幕）
@export var description: String = "这是物品的描述"

## 是否可以记录进发现册
@export var can_record: bool = false

## ItemDetail 弹窗的引用（由主场景传入）
var item_detail_ui: CanvasLayer


# ==================== 初始化 ====================
func _ready() -> void:
	# 连接点击信号
	input_event.connect(_on_input_event)


# ==================== 信号处理 ====================
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		# 调用 ItemDetail 弹窗显示
		if item_detail_ui:
			item_detail_ui.show_detail(
				detail_image,
				description,
				item_id,
				can_record
			)
