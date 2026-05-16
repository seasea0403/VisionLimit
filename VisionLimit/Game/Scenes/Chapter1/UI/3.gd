extends Control

# ==================== 可配置项 ====================
## 视频播放完毕后显示的旁白/对话（可在 Inspector 中直接修改）
@export_multiline var dialogue_text: String = "所有工单已处理完毕。\n\n系统归档正在进行——\n检测到 1 处缓存索引异常。已自动标记。\n\n……\n\n右下角信息图标亮了一下。\n不是系统通知。\n\n是邮件。"

## ItemDetail 面板的标题（可在 Inspector 修改）
@export var dialogue_title: String = "系统提示"

## 角色立绘纹理（可在 Inspector 拖入）
@export var character_image: Texture2D

## 邮件面板场景（在 Inspector 中拖入 4.tscn）
@export var email_panel_scene: PackedScene

# ==================== 节点引用 ====================
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var trigger_button: Button = $content/Button

var _item_detail: CanvasLayer = null


# ==================== 初始化 ====================
func _ready() -> void:
	video_player.visible = false

	# 通过分组找到真正的 ItemDetail
	_item_detail = get_tree().get_first_node_in_group("item_detail")
	if not _item_detail:
		push_warning("[3.gd] 未找到 item_detail 分组节点，请确认 item_detail.gd 已 add_to_group(\"item_detail\")")

	trigger_button.pressed.connect(_on_trigger_button_pressed)
	video_player.finished.connect(_on_video_finished)


# ==================== 事件处理 ====================

## 点击黑块 → 隐藏黑块，播放视频
func _on_trigger_button_pressed() -> void:
	trigger_button.visible = false
	video_player.visible = true
	video_player.play()


## 视频播放完毕 → 隐藏视频，显示 ItemDetail
func _on_video_finished() -> void:
	video_player.visible = false
	if _item_detail:
		_item_detail.panel_closed.connect(_on_item_detail_closed, CONNECT_ONE_SHOT)
		_item_detail.show_detail(
			null, dialogue_text, dialogue_title, false, "",
			Vector2.ONE, Vector2.ZERO, "", "", "", "",
			character_image
		)
	else:
		push_warning("[3.gd] 找不到 ItemDetail，直接跳到邮件面板")
		_open_email_panel()


## ItemDetail 关闭 → 弹出邮件面板
func _on_item_detail_closed() -> void:
	_open_email_panel()


func _open_email_panel() -> void:
	if email_panel_scene:
		var email: Control = email_panel_scene.instantiate()
		get_tree().get_root().add_child(email)
	else:
		push_warning("[3.gd] email_panel_scene 未设置，请在 Inspector 中拖入 4.tscn")
	queue_free()
