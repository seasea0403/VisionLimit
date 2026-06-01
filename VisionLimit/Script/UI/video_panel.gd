extends CanvasLayer

# ==================== 节点引用 ====================
@onready var video_player: VideoStreamPlayer = $VideoPlayer
@onready var close_button: Button = $CloseButton
@onready var dark_background: ColorRect = $ColorRect

# ==================== 视频结束后显示 ItemDetail ====================
## 是否在视频播放完毕后自动显示 ItemDetail
@export var show_detail_after_video: bool = false
## ItemDetail 标题
@export var detail_title: String = ""
## ItemDetail 正文（对话内容）
@export_multiline var detail_description: String = ""
## 物品图片（显示在详情面板的 ImageDisplay 位置）
@export var detail_item_image: Texture2D = null
## 物品 ID（非空且有图片时自动加入物品收藏，SumPanel / InferencePanel 均会刷新）
@export var detail_item_id: String = ""
## 角色立绘（同 ClickableItem 的 character_image 用法一致）
@export var detail_character_image: Texture2D = null

# ==================== 初始化 ====================
func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	video_player.finished.connect(_on_video_finished)
	dark_background.gui_input.connect(_on_background_clicked)
	
	hide()


# ==================== 公开接口 ====================
## 播放视频
func play_video(video_path: String) -> void:
	if not ResourceLoader.exists(video_path):
		push_error("视频文件不存在: " + video_path)
		return
	
	video_player.stream = load(video_path)
	show()
	video_player.play()
	print("▶ 正在播放视频: ", video_path)


## 停止并关闭视频面板
func close() -> void:
	video_player.stop()
	hide()


# ==================== 事件处理 ====================
func _on_close_pressed() -> void:
	close()


func _on_video_finished() -> void:
	print("✓ 视频播放完毕")
	await get_tree().create_timer(0.3).timeout
	hide()
	if show_detail_after_video:
		var item_detail = get_tree().get_first_node_in_group("item_detail")
		if item_detail:
			item_detail.show_detail(
				detail_item_image, detail_description, detail_title,
				false, detail_item_id, Vector2.ONE, Vector2.ZERO,
				"", "", "", "",
				detail_character_image
			)
		else:
			push_warning("[VideoPanel] 未找到 item_detail 分组节点")


func _on_background_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_ESCAPE, KEY_SPACE]:
			close()
			get_viewport().set_input_as_handled()
