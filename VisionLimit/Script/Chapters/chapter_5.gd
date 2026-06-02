extends "res://Script/Chapters/chapter.gd"

const Ch5End = preload("res://Script/Dialogues/ch5_end.gd")
const Ch5Intro = preload("res://Script/Dialogues/ch5_intro.gd")
const Ch5SceneIntro = preload("res://Script/Dialogues/ch5_scene_intro.gd")
const Ch6MemoryResult = preload("res://Script/Dialogues/ch6_memory_result.gd")
var confirm_panel_scene = preload("res://Game/Scenes/Chapter6/UI/confirmpanel.tscn")
var _confirm_panel_instance: Node = null

## 开场黑屏覆盖层
var _opening_overlay: CanvasLayer = null


func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(5)
	GameStateManager.reset_chapter_items(5)

	_opening_overlay = get_node_or_null("OpeningOverlay") as CanvasLayer

	# ── 从记忆海返回：跳过所有开场对话，直接进入醒来对话 ──────────────────
	if GameStateManager.get_record("ch6_return_from_memory") == "1":
		GameStateManager.set_record("ch6_return_from_memory", "")
		zoom_views_root.show()
		ui_layer.hide()
		if is_instance_valid(_opening_overlay):
			_opening_overlay.hide()
		DialogueManager.dialogue_finished.connect(_on_memory_result_finished, CONNECT_ONE_SHOT)
		DialogueManager.start_dialogue(Ch6MemoryResult.DATA, "0")
		return

	# 隐藏场景和 HUD，等待开场对话结束
	zoom_views_root.hide()
	ui_layer.hide()

	# 根据第四章是否拿到合照，决定是否播放路上对话
	if GameStateManager.get_record("ch4_got_photo_19") == "1":
		# 有合照 → 播放路上黑屏对话
		if not DialogueManager.dialogue_finished.is_connected(_on_intro_finished):
			DialogueManager.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
		DialogueManager.start_dialogue(Ch5Intro.DATA, "start")
	else:
		# 没有合照 → 跳过路上对话，直接显示场景并播放入场对话
		if is_instance_valid(_opening_overlay):
			_opening_overlay.hide()
		zoom_views_root.show()
		if not DialogueManager.dialogue_finished.is_connected(_on_scene_intro_finished):
			DialogueManager.dialogue_finished.connect(_on_scene_intro_finished, CONNECT_ONE_SHOT)
		DialogueManager.start_dialogue(Ch5SceneIntro.DATA, "start")


# ==================== 路上对话完成 ====================
func _on_intro_finished() -> void:
	if is_instance_valid(_opening_overlay):
		_opening_overlay.hide()
	zoom_views_root.show()
	# 启动工作室入场对话，HUD 仍隐藏
	if not DialogueManager.dialogue_finished.is_connected(_on_scene_intro_finished):
		DialogueManager.dialogue_finished.connect(_on_scene_intro_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch5SceneIntro.DATA, "start")


# ==================== 工作室入场对话完成 ====================
func _on_scene_intro_finished() -> void:
	ui_layer.show()
	# 如果记忆海已经完成，直接播放结局对话
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
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter6/chapter_5_2.tscn")

func _play_end_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_end_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_end_dialogue_finished, CONNECT_ONE_SHOT)
	
	DialogueManager.start_dialogue(Ch5End.DATA, "0")

func _on_end_dialogue_finished() -> void:
	GameStateManager.complete_chapter(5)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")


func _on_memory_result_finished() -> void:
	GameStateManager.complete_chapter(5)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
