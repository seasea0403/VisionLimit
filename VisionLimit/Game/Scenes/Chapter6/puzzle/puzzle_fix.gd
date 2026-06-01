extends Control

## Timeline puzzle main controller
## All nodes are placed statically in .tscn — adjust position/size/properties in editor

signal puzzle_completed

var _filled_count: int = 0


func _ready() -> void:
	# Connect slot_filled signal from all PuzzleTimelineSlot children
	for child in get_children():
		if child is PuzzleTimelineSlot:
			child.slot_filled.connect(_on_slot_filled)


func _on_slot_filled() -> void:
	_filled_count += 1
	if _filled_count >= 10:
		puzzle_completed.emit()
