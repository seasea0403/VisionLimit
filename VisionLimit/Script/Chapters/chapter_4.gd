extends "res://Script/Chapters/chapter.gd"

const Ch4Lab = preload("res://Script/Dialogues/ch4_lab.gd")

var _weijian_clicked: bool = false
var _saw_proof: bool = false  # item_id="7"  转账记录（打印机旁三页纸）
var _saw_b2: bool = false     # item_id="9"  B2格档案柜内档案
var _saw_card: bool = false   # item_id="6"  工位牌
var _saw_log: bool = false    # item_id="8"  外业勘测日志
var _saw_cup: bool = false    # item_id="3"  量杯


func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(4)
	GameStateManager.reset_chapter_items(4)
	item_detail.detail_opened.connect(_on_detail_opened)


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



func _start_lab_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_lab_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_lab_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch4Lab.DATA, "start")


func _on_lab_dialogue_finished() -> void:
	GameStateManager.complete_chapter(4)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
