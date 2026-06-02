extends "res://Script/Chapters/chapter.gd"

const Ch4Lab = preload("res://Script/Dialogues/ch4_lab.gd")
const Ch4Intro = preload("res://Script/Dialogues/ch4_intro.gd")
const Ch4Archive = preload("res://Script/Dialogues/ch4_archive.gd")
const Ch4InferenceFinish = preload("res://Script/Dialogues/ch4_inference_finish.gd")

var _weijian_clicked: bool = false
var _saw_proof: bool = false  # item_id="7"  转账记录（打印机旁三页纸）
var _saw_b2: bool = false     # item_id="9"  B2格档案柜内档案
var _saw_card: bool = false   # item_id="6"  工位牌
var _saw_log: bool = false    # item_id="8"  外业勘测日志
var _saw_cup: bool = false    # item_id="3"  量杯
var _saw_photo: bool = false  # item_id="19" 合照（影响结局）
var _saw_things1: bool = false # item_id="20" 信件（影响结局）

## 开场黑屏覆盖层
var _opening_overlay: CanvasLayer = null
## 提示覆盖层
var _hint_overlay: CanvasLayer = null
## 倒计时标签（UILayer/CountdownLabel）
var _countdown_label: Label = null
## 倒计时剩余秒数（10 分钟）
var _countdown_remaining: float = 600.0
## 倒计时 Timer 节点
var _countdown_timer: Timer = null
## 玩家是否已成功提交推理板
var _inference_solved: bool = false


func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(4)
	GameStateManager.reset_chapter_items(4)
	item_detail.detail_opened.connect(_on_detail_opened)

	# 获取覆盖层节点
	_opening_overlay = get_node_or_null("OpeningOverlay") as CanvasLayer
	_hint_overlay = get_node_or_null("HintOverlay") as CanvasLayer
	_countdown_label = get_node_or_null("UILayer/CountdownLabel") as Label

	# 隐藏实验室场景和 HUD，等待开场对话结束后再显示
	zoom_views_root.hide()
	ui_layer.hide()

	# 启动开场对话
	if not DialogueManager.dialogue_finished.is_connected(_on_intro_finished):
		DialogueManager.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch4Intro.DATA, "start")


# ==================== 开场对话完成 ====================
func _on_intro_finished() -> void:
	# 隐藏黑屏覆盖层，显示场景背景
	if is_instance_valid(_opening_overlay):
		_opening_overlay.hide()
	zoom_views_root.show()
	# HUD 暂不显示，等档案室对话结束后再开放
	# 启动档案室入场对话
	if not DialogueManager.dialogue_finished.is_connected(_on_archive_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_archive_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch4Archive.DATA, "start")


# ==================== 档案室入场对话完成 ====================
func _on_archive_dialogue_finished() -> void:
	# 显示提示覆盖层
	if is_instance_valid(_hint_overlay):
		_hint_overlay.show()
		var dismiss_btn := _hint_overlay.get_node_or_null("DismissButton") as Button
		if dismiss_btn and not dismiss_btn.is_connected("pressed", _on_hint_dismissed):
			dismiss_btn.connect("pressed", _on_hint_dismissed)
	else:
		# 若节点不存在则直接开放 HUD
		ui_layer.show()


# ==================== 提示确认（开场提示，进入搜证阶段）====================
func _on_hint_dismissed() -> void:
	if is_instance_valid(_hint_overlay):
		_hint_overlay.hide()
	ui_layer.show()
	_start_countdown()


# ==================== 倒计时 ====================
func _start_countdown() -> void:
	# 连接推理板成功信号
	if is_instance_valid(inference_panel) and inference_panel.has_signal("inference_success"):
		if not inference_panel.is_connected("inference_success", _on_inference_solved):
			inference_panel.connect("inference_success", _on_inference_solved)
		if not inference_panel.is_connected("chapter_next_requested", _on_inference_next_pressed):
			inference_panel.connect("chapter_next_requested", _on_inference_next_pressed)

	# 更新显示并启动每秒 tick 的 Timer
	_update_countdown_display()
	_countdown_timer = Timer.new()
	_countdown_timer.wait_time = 1.0
	_countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(_countdown_timer)
	_countdown_timer.start()


func _on_countdown_tick() -> void:
	_countdown_remaining -= 1.0
	_update_countdown_display()
	if _countdown_remaining <= 0.0:
		_countdown_timer.stop()
		_on_countdown_expired()


func _update_countdown_display() -> void:
	if is_instance_valid(_countdown_label):
		var mins := int(_countdown_remaining) / 60
		var secs := int(_countdown_remaining) % 60
		_countdown_label.text = "%02d:%02d" % [mins, secs]


func _on_inference_solved() -> void:
	_inference_solved = true
	if is_instance_valid(_countdown_timer):
		_countdown_timer.stop()
	# 倒计时完成使命，隐藏标签
	if is_instance_valid(_countdown_label):
		_countdown_label.hide()
	
	# 显示推理板完成后的按钮（下一步、继续探索、已完成）
	if is_instance_valid(inference_panel):
		inference_panel.show_completion_buttons()


func _on_inference_next_pressed() -> void:
	if is_instance_valid(inference_panel):
		inference_panel.hide()
	
	# 启动推理完成后的对话
	if not DialogueManager.dialogue_finished.is_connected(_on_inference_finish_dialogue_done):
		DialogueManager.dialogue_finished.connect(_on_inference_finish_dialogue_done, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch4InferenceFinish.DATA, "start")


func _on_inference_finish_dialogue_done() -> void:
	# 对话完成后，解锁下一关并转场
	GameStateManager.complete_chapter(4)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")


func _on_countdown_expired() -> void:
	if _inference_solved:
		return
	# 隐藏倒计时标签
	if is_instance_valid(_countdown_label):
		_countdown_label.hide()
	# 复用 HintOverlay，换成失败文字
	if is_instance_valid(_hint_overlay):
		var label := _hint_overlay.get_node_or_null("HintLabel") as Label
		if label:
			label.text = "【很遗憾，没能找到足够多的线索，下次再来尝试吧】"
		var dismiss_btn := _hint_overlay.get_node_or_null("DismissButton") as Button
		if dismiss_btn:
			if dismiss_btn.is_connected("pressed", _on_hint_dismissed):
				dismiss_btn.disconnect("pressed", _on_hint_dismissed)
			if not dismiss_btn.is_connected("pressed", _on_timeout_dismissed):
				dismiss_btn.connect("pressed", _on_timeout_dismissed)
		_hint_overlay.show()


# ==================== 超时后点击——返回选关，不解锁下一章 ====================
func _on_timeout_dismissed() -> void:
	if is_instance_valid(_hint_overlay):
		_hint_overlay.hide()
	# 不调用 GameStateManager.complete_chapter，直接回选关页面
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")


func _on_detail_opened(item_id: String) -> void:
	match item_id:
		"1":  # 魏江
			if not _weijian_clicked:
				_weijian_clicked = true
			else:
				item_detail.close_detail()
				_start_lab_dialogue()
		"7":  # 转账记录
			if not _saw_proof:
				_saw_proof = true
				GameStateManager.set_clue("clue_funds")
		"9":  # B2格档案柜内档案
			if not _saw_b2:
				_saw_b2 = true
				GameStateManager.set_clue("clue_archive")
		"6":  # 工位牌 — 查看即解锁档案删除节点线索
			if not _saw_card:
				_saw_card = true
				GameStateManager.set_clue("clue_person")
		"8":  # 外业勘测日志 — 查看即解锁
			if not _saw_log:
				_saw_log = true
				GameStateManager.set_clue("clue_person")
		"3":  # 量杯 — 查看即解锁
			if not _saw_cup:
				_saw_cup = true
				GameStateManager.set_clue("clue_person")
		"19":  # 合照 — 影响结局
			if not _saw_photo:
				_saw_photo = true
				GameStateManager.set_record("saw_photo", "true")
				_check_found_archive()
		"20":  # 信件 — 影响结局
			if not _saw_things1:
				_saw_things1 = true
				GameStateManager.set_record("saw_things1", "true")
				_check_found_archive()

func _check_found_archive() -> void:
	if GameStateManager.get_record("saw_photo") == "true" and GameStateManager.get_record("saw_things1") == "true":
		GameStateManager.set_clue("ch3_found_archive")



func _start_lab_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_lab_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_lab_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch4Lab.DATA, "start")


func _on_lab_dialogue_finished() -> void:
	GameStateManager.complete_chapter(4)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
