extends Node2D

# ==================== 子节点引用 ====================
@onready var clickable_area = $Items/ClickableArea
@onready var clickable_item = $Items/ClickableItem
@onready var item_detail_ui = $UILayer/ItemDetail


# ==================== 初始化 ====================
func _ready() -> void:
	# 为 ClickableArea 设置参数
	clickable_area.zoom_view_scene = preload("res://Scenes/ZoomViews/ZoomView_Desk.tscn")
	clickable_area.main_scene = self
	
	# 为 ClickableItem 设置参数
	clickable_item.item_detail_ui = item_detail_ui
	
	print("Chapter1Test 已初始化")
