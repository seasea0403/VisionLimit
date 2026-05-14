extends Control

@export var chapter_index: int = 1
@export var is_unlocked: bool = false

@onready var lock_overlay: Control = $LockOverlay
@onready var select_buttons: VBoxContainer = $SelectButtons

func _ready() -> void:
	is_unlocked = ChapterProgressManager.is_chapter_unlocked(chapter_index)
	_update_ui_state()

func _update_ui_state() -> void:
	if not is_unlocked:
		lock_overlay.visible = true
		select_buttons.disabled = true
	else:
		lock_overlay.visible = false
		select_buttons.disabled = false
