extends Control

# ==================== 可配置项 ====================
## 关闭邮件后弹出的第二个 ItemDetail 对话（可在 Inspector 中修改）
@export_multiline var dialogue_text_2: String = "邮件已读。\n\n……\n\n是江院长发来的。\n内容是关于「近视管控系数」调整的通知。\n\n就这样。\n什么都没有多说。"

## 第二个 ItemDetail 的标题（可在 Inspector 修改）
@export var dialogue_title_2: String = "系统提示"

## 第二个 ItemDetail 的角色立绘（可在 Inspector 拖入）
@export var character_image_2: Texture2D
@export var character_scale_2: Vector2 = Vector2.ONE
@export var character_offset_2: Vector2 = Vector2.ZERO

# ==================== 节点引用 ====================
@onready var close_button: Button = $CloseButton

var _item_detail: CanvasLayer = null


# ==================== 初始化 ====================
func _ready() -> void:
	_item_detail = get_tree().get_first_node_in_group("item_detail")
	if not _item_detail:
		push_warning("[4.gd] 未找到 item_detail 分组节点")
	close_button.pressed.connect(_on_close_pressed)


# ==================== 事件处理 ====================

## 点击关闭按钮 → 弹出第二个 ItemDetail
func _on_close_pressed() -> void:
	close_button.visible = false
	if _item_detail:
		_item_detail.panel_closed.connect(_on_second_item_detail_closed, CONNECT_ONE_SHOT)
		_item_detail.show_detail(
			null, dialogue_text_2, dialogue_title_2, false, "",
			Vector2.ONE, Vector2.ZERO, "", "", "", "",
			character_image_2, character_scale_2, character_offset_2
		)
	else:
		push_warning("[4.gd] 找不到 ItemDetail，直接结束章节")
		_finish_chapter()


## 第二个 ItemDetail 关闭 → 等待 2 秒 → 解锁下一章 → 返回关卡选择
func _on_second_item_detail_closed() -> void:
	await get_tree().create_timer(2.0).timeout
	_finish_chapter()


func _finish_chapter() -> void:
	GameStateManager.complete_chapter(1)
	queue_free()  # 先移除自身，避免 4.tscn 在切换场景后残留
	get_tree().change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
