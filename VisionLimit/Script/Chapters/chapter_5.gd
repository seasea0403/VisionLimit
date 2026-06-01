extends "res://Script/Chapters/chapter.gd"

const Ch5End = preload("res://Script/Dialogues/ch5_end.gd")
var confirm_panel_scene = preload("res://Game/Scenes/Chapter6/UI/confirmpanel.tscn")
var _confirm_panel_instance: Node = null

func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(5)
	GameStateManager.reset_chapter_items(5)
	
	# 如果记忆海已经完成
	if GameStateManager.get_record("ch5_memory_completed") == "1":
		_play_end_dialogue()
	else:
		item_detail.detail_opened.connect(_on_detail_opened)

func _on_detail_opened(item_id: String) -> void:
	# 检查玩家是否点击了电脑 (itemID = "7")
	if item_id == "7":
		# 强制关闭原有的详情面板
		item_detail.close_detail()
		
		# 弹出确认面板
		if not _confirm_panel_instance:
			_confirm_panel_instance = confirm_panel_scene.instantiate()
			add_child(_confirm_panel_instance)
			_confirm_panel_instance.confirmed.connect(_on_memory_dive_confirmed)
		
		_confirm_panel_instance.show_popup("系统提示", "是否确认进行记忆扫描？\n警告：此过程将以患者神经模板形式重启你自身的接入路径，存在不可逆风险。")


func _on_memory_dive_confirmed() -> void:
	# 确认后进入记忆海场景（第六章）
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter6/chapter_6.tscn")

func _play_end_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_end_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_end_dialogue_finished, CONNECT_ONE_SHOT)
	
	DialogueManager.start_dialogue(Ch5End.DATA, "0")

func _on_end_dialogue_finished() -> void:
	GameStateManager.complete_chapter(5)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
