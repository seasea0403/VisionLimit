extends Control

const Ch1Email = preload("res://Script/Dialogues/ch1_email.gd")

# ==================== 节点引用 ====================
@onready var close_button: Button = $CloseButton
@onready var back_button: TextureButton = $back/TextureButton


# ==================== 初始化 ====================
func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	hide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		var hud := _get_hud_panel()
		if hud:
			if visible:
				hud.hide()
			else:
				hud.show()


func _get_hud_panel() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().get_root().find_child("HudPanel", true, false)


# ==================== 事件处理 ====================

## 点击关闭按钮 → 启动沈意对话
func _on_close_pressed() -> void:
	close_button.visible = false
	back_button.visible = false
	DialogueManager.dialogue_finished.connect(_finish_chapter, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch1Email.DATA, "start")


func _finish_chapter() -> void:
	GameStateManager.complete_chapter(1)
	queue_free()  # 先移除自身，避免 4.tscn 在切换场景后残留
	get_tree().change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
