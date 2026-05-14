# ChapterSelectPanel.gd
extends Control

@export var scroll_speed: float = 0.3  # 滑动速度

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var h_box: HBoxContainer = $ScrollContainer/HBoxContainer

var current_chapter: int = 1
var total_chapters: int = 7

func _ready():
	scroll_to_chapter(1)

func scroll_to_chapter(chapter_index: int) -> void:
	current_chapter = clampi(chapter_index, 1, total_chapters)
	var target_scroll: int = (current_chapter - 1) * int(get_viewport_rect().size.x)
	
	# 平滑滚动
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(scroll_container, "scroll_horizontal", target_scroll, scroll_speed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
			scroll_to_chapter(current_chapter - 1)
			get_tree().root.set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
			scroll_to_chapter(current_chapter + 1)
			get_tree().root.set_input_as_handled()
