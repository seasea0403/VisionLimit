extends "res://Script/Chapters/chapter.gd"

const Ch6_1Intro = preload("res://Script/Dialogues/ch6_1_intro.gd")

func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(7)
	GameStateManager.reset_chapter_items(7)

	zoom_views_root.hide()
	ui_layer.hide()

	if not DialogueManager.dialogue_finished.is_connected(_on_intro_finished):
		DialogueManager.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch6_1Intro.DATA, "start")


func _on_intro_finished() -> void:
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter7/2/chapter_6_2.tscn")
