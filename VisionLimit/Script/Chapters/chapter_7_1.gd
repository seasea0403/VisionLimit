extends "res://Script/Chapters/chapter.gd"

const Ch7SuLin = preload("res://Script/Dialogues/ch7_sulin.gd")
var ui_scene1 = preload("res://Game/Scenes/Chapter7/1/UI/1.tscn")
var _proof_scene = preload("res://Game/Scenes/Chapter7/UI/proofpanel.tscn")

var _ui_instance: Node = null
var _ui_layer: CanvasLayer = null
var _proof_layer: CanvasLayer = null
var _dialogue_done: bool = false

func _ready() -> void:
	super._ready()
	item_detail.detail_opened.connect(_on_detail_opened)

	# 预先实例化苏临 UI，消除点击时的加载延迟
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 5
	add_child(_ui_layer)

	_ui_instance = ui_scene1.instantiate()
	_ui_instance.visible = false
	_ui_layer.add_child(_ui_instance)

	# 提前连接返回按钮，避免对话结束后再动态连接
	var back_btn := _ui_instance.get_node_or_null("back/TextureButton") as TextureButton
	if back_btn != null:
		back_btn.pressed.connect(_on_back_pressed)

func _on_detail_opened(item_id: String) -> void:
	if item_id == "7":
		item_detail.close_detail()

		if _dialogue_done:
			# 对话已结束，点击电脑打开证据板
			_show_proof_panel()
			return

		# 直接显示预建 UI，无需重新实例化
		_ui_instance.visible = true
		_play_sulin_dialogue()

func _play_sulin_dialogue() -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_sulin_dialogue_finished):
		DialogueManager.dialogue_finished.connect(_on_sulin_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch7SuLin.DATA, "start")

func _on_sulin_dialogue_finished() -> void:
	# 对话结束：显示 back 节点（包含整个返回按钮）
	var back_node := _ui_instance.get_node_or_null("back")
	if back_node != null:
		back_node.visible = true

func _on_back_pressed() -> void:
	# 隐藏整个 UI，重置 back 节点，标记对话已完成
	_ui_instance.visible = false
	var back_node := _ui_instance.get_node_or_null("back")
	if back_node != null:
		back_node.visible = false
	_dialogue_done = true

func _show_proof_panel() -> void:
	if is_instance_valid(_proof_layer):
		return
	_proof_layer = CanvasLayer.new()
	_proof_layer.layer = 5
	add_child(_proof_layer)

	var proof: Node = _proof_scene.instantiate()
	_proof_layer.add_child(proof)
