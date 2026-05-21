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
		"6":  # 工位牌
			if not _saw_card:
				_saw_card = true
				_check_person_clue()
		"8":  # 外业勘测日志
			if not _saw_log:
				_saw_log = true
				_check_person_clue()
		"3":  # 量杯
			if not _saw_cup:
				_saw_cup = true
				_check_person_clue()


func _check_person_clue() -> void:
	if _saw_card and _saw_log and _saw_cup:
		GameStateManager.set_clue("clue_person")


func _start_lab_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_lab_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_lab_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch4Lab.DATA, "start")


func _on_lab_dialogue_finished() -> void:
	GameStateManager.complete_chapter(4)
	get_tree().change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
