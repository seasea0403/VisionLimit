extends "res://Script/Chapters/chapter.gd"

const Ch3Dock = preload("res://Script/Dialogues/ch3_dock.gd")

# ========== 线索追踪状态 ==========
var _weijian_clicked: bool = false  # 魏江 NPC 第一次点击标记
var _saw_book:  bool = false         # item_id="6"  魏江采访本（scene 中覆盖原 id="1"）
var _saw_note:  bool = false         # item_id="2"  电子价牌（黄色便签纸）
var _saw_tag:   bool = false         # item_id="3"  渔获筐标签
var _saw_board: bool = false         # 码头泊位告示牌（Zoomview visibility_changed 检测）


func _ready() -> void:
	super._ready()
	item_detail.detail_opened.connect(_on_detail_opened)
	# 码头泊位告示牌通过 zoomview 可见性变化检测（该 zoomview 无 item_id）
	var board_zv = $"ZoomViews/ClickableArea_priceboard2/Zoomview_information"
	if board_zv:
		board_zv.visibility_changed.connect(_on_board_visible_changed)


func _on_detail_opened(item_id: String) -> void:
	match item_id:
		"1":  # 魏江 NPC
			if not _weijian_clicked:
				_weijian_clicked = true
			else:
				item_detail.close_detail()
				_start_dock_dialogue()
		"6":  # 魏江采访本— 环境检测及价格异常两条线索的起点
			if not _saw_book:
				_saw_book = true
				GameStateManager.set_clue("clue_inspect")
				GameStateManager.set_clue("clue_price")
		"2":  # 电子价牌（黄色便签纸）— 查看即解锁价格线索
			if not _saw_note:
				_saw_note = true
				GameStateManager.set_clue("clue_price")
		"3":  # 渔获筐标签 — 查看即解锁溯源线索
			if not _saw_tag:
				_saw_tag = true
				GameStateManager.set_clue("clue_trace")


func _on_board_visible_changed() -> void:
	var board_zv = $"ZoomViews/ClickableArea_priceboard2/Zoomview_information"
	if board_zv and board_zv.visible and not _saw_board:
		_saw_board = true
		GameStateManager.set_clue("clue_trace")



func _start_dock_dialogue() -> void:
	# 防止玩家选「我再走一圈」退出后再次触发时重复连接
	if not DialogueManager.dialogue_finished.is_connected(_on_dock_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_dock_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch3Dock.DATA, "start")


func _on_dock_dialogue_finished() -> void:
	# complete_chapter(3) 在 chapter_3_1 中已调用过（幂等），此处再调一次无害；
	# 同时解锁第四章（confirm chapter index matches GameStateManager logic）
	GameStateManager.complete_chapter(3)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
