extends CanvasLayer

const FADE_OUT_DURATION := 0.45
const FADE_IN_DURATION := 0.7
const BGM_FADE_OUT_DURATION := 0.35
const BGM_FADE_IN_DURATION := 1.2
const MIN_BGM_VOLUME_DB := -40.0

var _overlay: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_overlay = ColorRect.new()
	_overlay.name = "SceneTransitionOverlay"
	_overlay.color = Color(0, 0, 0, 1)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	if not get_tree().scene_changed.is_connected(_on_scene_changed):
		get_tree().scene_changed.connect(_on_scene_changed)

	call_deferred("_fade_in_current_scene")


func change_scene_to_file(path: String) -> void:
	if path.is_empty() or _is_transitioning:
		return

	_is_transitioning = true
	await _fade_to_black()

	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_warning("[SceneTransitionManager] scene change failed: %s" % path)
		await _fade_from_black()
		_is_transitioning = false


func _on_scene_changed() -> void:
	await get_tree().process_frame
	await _fade_from_black()
	_is_transitioning = false


func _fade_in_current_scene() -> void:
	await get_tree().process_frame
	await _fade_from_black()


func _fade_to_black() -> void:
	_overlay.visible = true
	var tween := create_tween()
	tween.tween_property(_overlay, "color", Color(0, 0, 0, 1), FADE_OUT_DURATION)

	var bgm = _find_scene_bgm(get_tree().current_scene)
	if bgm != null and bgm.playing:
		tween.parallel().tween_property(bgm, "volume_db", MIN_BGM_VOLUME_DB, BGM_FADE_OUT_DURATION)

	await tween.finished


func _fade_from_black() -> void:
	_overlay.visible = true
	_overlay.color = Color(0, 0, 0, 1)

	var tween := create_tween()
	tween.tween_property(_overlay, "color", Color(0, 0, 0, 0), FADE_IN_DURATION)

	var bgm = _find_scene_bgm(get_tree().current_scene)
	if bgm != null and bgm.playing and bgm.volume_db > MIN_BGM_VOLUME_DB + 0.5:
		var target_volume = bgm.volume_db
		bgm.volume_db = MIN_BGM_VOLUME_DB
		tween.parallel().tween_property(bgm, "volume_db", target_volume, BGM_FADE_IN_DURATION)

	await tween.finished
	_overlay.visible = false


func _find_scene_bgm(scene: Node):
	if scene == null:
		return null

	var named_bgm = scene.find_child("SceneBgm", true, false)
	if named_bgm is AudioStreamPlayer or named_bgm is AudioStreamPlayer2D:
		return named_bgm

	var panel_bgm = scene.find_child("AudioStreamPlayer2D", true, false)
	if panel_bgm is AudioStreamPlayer or panel_bgm is AudioStreamPlayer2D:
		return panel_bgm

	return null
