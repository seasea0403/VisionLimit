extends Node2D

@onready var item_detail = $UILayer/ItemDetail
@onready var zoom_views_root = $ZoomViews
@onready var clickable_areas = $ZoomViews.get_children()


func _ready():
	# 可点击区域必须可见，否则 input_event 不会触发
	zoom_views_root.show()
	for area in clickable_areas:
		area.show()
		# 仅隐藏每个区域里的放大视图，不隐藏可点击区域本体
		for child in area.get_children():
			if child.has_method("hide_view"):
				child.hide_view()

	item_detail.hide() # 隐藏详情面板
	print("Chapter1 场景已准备好：ClickableArea 可见，ZoomView 已隐藏")
