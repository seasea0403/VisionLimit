extends Node

# 对话结束时发出，携带本次对话记录下的所有选择
signal dialogue_finished

const PANEL_SCENE_PATH := "res://Game/UI/DialoguePanel/DialoguePanel.tscn"

var _panel: Node = null
var _dialogue_nodes: Dictionary = {}

## 当前是否有对话框正在显示（供 ClickableArea/Item/Video 屏蔽穿透点击用）
var is_active: bool:
	get: return is_instance_valid(_panel) and _panel.visible


func start_dialogue(dialogue_data: Dictionary, start_id: String = "start") -> void:
	"""从任意脚本调用，传入对话数据字典和起始节点 ID"""
	_dialogue_nodes = dialogue_data

	if not is_instance_valid(_panel):
		var scene: PackedScene = load(PANEL_SCENE_PATH)
		_panel = scene.instantiate()
		get_tree().current_scene.add_child(_panel)
		_panel.advance_requested.connect(advance)

	_panel.show()
	_go_to_node(start_id)


func advance(next_id: String, record_key: String = "", record_value: String = "") -> void:
	"""由 DialoguePanel 内部按钮调用，推进到下一个节点"""
	if record_key != "":
		GameStateManager.set_record(record_key, record_value)

	# "__exit__" 表示玩家选择退出对话继续探索，仅关闭面板，不发 dialogue_finished 信号
	if next_id == "__exit__":
		if is_instance_valid(_panel):
			_panel.hide()
		return

	if next_id == "" or not _dialogue_nodes.has(next_id):
		_end_dialogue()
	else:
		_go_to_node(next_id)


func _go_to_node(node_id: String) -> void:
	if not _dialogue_nodes.has(node_id):
		_end_dialogue()
		return
	_panel.load_node(_dialogue_nodes[node_id])


func _end_dialogue() -> void:
	if is_instance_valid(_panel):
		_panel.hide()
	dialogue_finished.emit()
