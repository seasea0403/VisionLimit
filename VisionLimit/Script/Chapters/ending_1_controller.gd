extends Node2D

const DIALOGUE_DATA = preload("res://Script/Dialogues/ch7_ending_1.gd")

func _ready() -> void:
	# 稍微延迟启动，确保场景加载完毕
	await get_tree().create_timer(1.0).timeout
	start_ending_dialogue()

func start_ending_dialogue() -> void:
	DialogueManager.start_dialogue(DIALOGUE_DATA.DATA)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	# 对话完成后进入游戏选择页面
	# 如果没有专门的选择页面，通常返回主菜单或剧目选择
	# 这里假设返回主面板或者关卡选择
	if FileAccess.file_exists("res://Game/UI/MainPanel.tscn"):
		SceneTransitionManager.change_scene_to_file("res://Game/UI/UIPanel.tscn")
	else:
		# 退而求其次
		SceneTransitionManager.change_scene_to_file("res://Template/UI/Level.tscn")
