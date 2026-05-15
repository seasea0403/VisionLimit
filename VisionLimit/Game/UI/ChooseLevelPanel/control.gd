extends Control

@onready var scroll_container = get_parent().find_child("ScrollContainer")
var lines: Array[Node] = []
var original_positions: Array[float] = []
var original_scales: Array[Vector2] = []
var original_sizes: Array[Vector2] = []

func _ready():
	# 获取所有标记为 "grid_lines" 的节点
	lines = get_tree().get_nodes_in_group("grid_lines")
	
	# 保存初始位置、缩放和大小
	for line in lines:
		original_positions.append(line.offset_left)
		original_scales.append(line.scale)
		original_sizes.append(line.size)
	
	scroll_container.scroll_ended.connect(_on_scroll)

func _process(_delta):
	_update_lines_position()

func _update_lines_position():
	var scroll_x = scroll_container.get_h_scroll_bar().value
	
	for i in range(lines.size()):
		# 只改变位置，保持缩放和大小不变
		lines[i].offset_left = original_positions[i] - scroll_x
		lines[i].scale = original_scales[i]
		lines[i].size = original_sizes[i]

func _on_scroll():
	_update_lines_position()
