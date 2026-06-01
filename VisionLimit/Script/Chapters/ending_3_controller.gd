extends Node2D

const DIALOGUE_DATA = preload("res://Script/Dialogues/ch7_ending_3.gd")

func _ready() -> void:
	# 稍微延迟启动，确保场景加载完毕
	await get_tree().create_timer(1.0).timeout
	start_ending_dialogue()

func start_ending_dialogue() -> void:
	DialogueManager.start_dialogue(DIALOGUE_DATA.DATA)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	if FileAccess.file_exists("res://Game/UI/MainPanel.tscn"):
		SceneTransitionManager.change_scene_to_file("res://Game/UI/MainPanel.tscn")
	else:
		SceneTransitionManager.change_scene_to_file("res://Template/UI/Level.tscn")
