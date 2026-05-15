extends TextureButton

@export var scene_path: String = ""
@export var chapter_index: int = 1

func _ready():
	print("✓ TextureButton ready!")
	print("  scene_path: %s" % scene_path)
	print("  chapter_index: %d" % chapter_index)
	print("  GameStateManager exists: %s" % (GameStateManager != null))
	
	pressed.connect(_on_pressed)
	update_button_state()

func update_button_state():
	if GameStateManager == null:
		print("✗ GameStateManager is NULL!")
		disabled = false  # 暂时启用按钮以便测试跳转
		modulate = Color.WHITE
		return
	
	var is_unlocked = GameStateManager.is_chapter_unlocked(chapter_index)
	print("✓ Chapter %d unlocked: %s" % [chapter_index, is_unlocked])
	
	disabled = !is_unlocked
	modulate = Color.WHITE if is_unlocked else Color(0.035, 0.035, 0.035, 1.0)

func _on_pressed():
	print("━━━ BUTTON PRESSED ━━━")
	print("scene_path: '%s'" % scene_path)
	print("disabled: %s" % disabled)
	print("scene_path empty: %s" % (scene_path == ""))
	
	if scene_path == "":
		print("✗ ERROR: scene_path is empty!")
		return
	
	if disabled:
		print("✗ Button is disabled")
		return
	
	print("✓ Attempting to change scene to: %s" % scene_path)
	var error = get_tree().change_scene_to_file(scene_path)
	print("Scene change result: %d (0 = OK)" % error)
