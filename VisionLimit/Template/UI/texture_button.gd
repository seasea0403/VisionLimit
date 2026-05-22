extends TextureButton

@export var scene_path: String = ""
@export var chapter_index: int = 1

func _ready():
	pressed.connect(_on_pressed)
	update_button_state()

func update_button_state():
	if GameStateManager == null:
		disabled = false
		return

	var is_unlocked = GameStateManager.is_chapter_unlocked(chapter_index)
	disabled = !is_unlocked
	# 通过 Node2D2（包含所有视觉元素）统一控制整张卡片的外观，
	# 避免与 UIbutton.gd 对 TextureButton.modulate 的管理冲突
	var visual_root = get_parent().get_parent()  # Node2D2
	if visual_root:
		visual_root.modulate = Color.WHITE if is_unlocked else Color(0.5, 0.5, 0.5, 1.0)

func _on_pressed():
	if scene_path == "" or disabled:
		return
	SceneTransitionManager.change_scene_to_file(scene_path)
