extends "res://Script/Chapters/chapter.gd"

# ==================== 对话数据 ====================
const Ch3Hospital = preload("res://Script/Dialogues/ch3_hospital.gd")

# ==================== 状态 ====================
## 魏江是否已被点击过一次（第一次=开场白，第二次=触发对话）
var _weijian_clicked: bool = false
## 是否已查看苍屿症宣传册（便签纸 item_id="5"）
var _saw_brochure: bool = false
## 是否已查看粉色便签（item_id="2"）
var _saw_pinknote: bool = false
## 是否已查看预约记录/台账（item_id="4"）
var _saw_record: bool = false


func _ready() -> void:
	super._ready()
	item_detail.detail_opened.connect(_on_detail_opened)


# ==================== 物品查看追踪 ====================
func _on_detail_opened(item_id: String) -> void:
	match item_id:
		"1":  # 魏江 — 第一次显示开场白，第二次开始对话
			if not _weijian_clicked:
				_weijian_clicked = true
			else:
				item_detail.close_detail()
				_start_hospital_dialogue()
		"5":  # 苍屿症宣传册（便签纸）
			if not _saw_brochure:
				_saw_brochure = true
				GameStateManager.set_clue("clue_brochure")
		"2":  # 粉色便签（查看即解锁预约异常线索）
			if not _saw_pinknote:
				_saw_pinknote = true
				GameStateManager.set_clue("clue_appointment")
		"4":  # 预约记录（台账）— 同样单独查看即解锁
			if not _saw_record:
				_saw_record = true
				GameStateManager.set_clue("clue_appointment")



# ==================== 医院对话 ====================
func _start_hospital_dialogue() -> void:
	# 防止玩家选「我再走一圈」退出后再次触发时重复连接
	if not DialogueManager.dialogue_finished.is_connected(_on_hospital_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_hospital_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch3Hospital.DATA, "start")


func _on_hospital_dialogue_finished() -> void:
	GameStateManager.complete_chapter(3)
	SceneTransitionManager.change_scene_to_file("res://Game/Scenes/Chapter3/2/chapter_3_2.tscn")
