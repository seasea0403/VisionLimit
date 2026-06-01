extends "res://Script/Chapters/chapter.gd"

# ==================== 状态机 ====================
enum State {
	LOCKPICK_INTRO,    # 开场：等待第一次点击，显示提示文字
	LOCKPICK_READY,    # 提示已读：等待第二次点击启动小游戏
	LOCKPICK_GAME,     # 开锁小游戏进行中
	EXPLORE,           # 初始探索（录音密码未解开）
	RECORD_PLAYING,    # RecordPlayer 面板播放中
	TRANSCRIPT_DONE,   # 录音播放完毕，等待 InferencePanel 完成
	ENDING_PART1,      # 结局对话第一段（大头 + 双人对话到推理板）
	PUZZLE2,           # 对话中途打开 UI/1 推理板
	ENDING_PART2,      # 结局对话第二段（推理板完成后）
}

var _state := State.LOCKPICK_INTRO

# ==================== 额外节点引用（章节特有）====================
@onready var _password_panel  = $UILayer/PasswordPanel
@onready var _record_audio: AudioStreamPlayer2D = $UILayer/RecordAudio
@onready var _puzzle_ui       = $"UILayer/1"
@onready var _hud_panel       = $UILayer/HudPanel
@onready var _open_record_btn: Node = $"UILayer/ItemDetail/Control/OpenRecordButton"
@onready var _items_root: Node2D = $Items

# ==================== 对话数据 ====================
const Ch2Ending = preload("res://Script/Dialogues/ch2_ending.gd")
const RECORD_PLAYER_SCENE = preload("res://Game/UI/RecordPlayer/RecordPlayer.tscn")

var _lockpick_minigame: Control = null
var _door_lock_entry: Node2D   = null

var _record_player: Control = null

# 录音是否已在本次章节中完整播放过（每次进入章节重置）
var _recording_done: bool = false
# 重播前保存的状态（播完后还原）
var _state_before_replay: State = State.EXPLORE

# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()
	GameStateManager.set_current_chapter(2)
	GameStateManager.reset_chapter_items(2)

	# 实例化并挂载 RecordPlayer 到 UILayer
	_record_player = RECORD_PLAYER_SCENE.instantiate()
	$UILayer.add_child(_record_player)
	_record_player.playback_done.connect(_on_record_playback_done)

	# 密码面板：连接正确信号
	_password_panel.password_correct.connect(_on_password_correct)

	# 仅 Chapter2 显示密码面板的返回按钮
	var _back_btn = _password_panel.get_node_or_null("VBoxContainer/BackButton")
	if _back_btn:
		_back_btn.visible = true

	# UI/1 推理板：连接完成信号（字符串形式，避免静态类型检查警告）
	_puzzle_ui.connect("puzzle_solved", _on_puzzle2_solved)

	# ItemDetail 信号
	item_detail.detail_opened.connect(_on_detail_opened)
	_open_record_btn.get_node("TextureButton").pressed.connect(_on_open_record_pressed)
	item_detail.panel_closed.connect(_on_item_detail_closed)

	# 录音笔在听完录音前不自动加入物品栏（每次进入章节重置）
	item_detail.no_auto_inventory_ids.clear()
	item_detail.no_auto_inventory_ids.append("3")

	# 开锁小游戏和门锁节点
	_lockpick_minigame = get_node_or_null("UILayer/LockpickMinigame")
	_door_lock_entry   = get_node_or_null("DoorLockEntry")

	if _lockpick_minigame:
		_lockpick_minigame.lockpick_success.connect(_on_lockpick_success)
		if _lockpick_minigame.has_signal("lockpick_failed"):
			_lockpick_minigame.lockpick_failed.connect(_on_lockpick_failed)
	else:
		push_warning("chapter2.gd: 找不到 LockpickMinigame 节点")

	if _door_lock_entry:
		_door_lock_entry.area_clicked.connect(_on_door_lock_clicked)
	else:
		push_warning("chapter2.gd: 找不到 DoorLockEntry 节点")

	# InferencePanel：提交正确显示「下一步」按钮，点击后触发结局序列
	if inference_panel and inference_panel.has_signal("chapter_next_requested"):
		inference_panel.inference_success.connect(inference_panel.show_completion_buttons)
		inference_panel.chapter_next_requested.connect(_on_inference_complete)
	else:
		# inference_panel 由父类延迟挂载，等一帧后再连接
		call_deferred("_connect_inference_panel")

	# ==================== 开锁前置初始化 ====================
	if GameStateManager.get_record("ch2_lockpick_done") == "true":
		_state = State.EXPLORE
		if _door_lock_entry:
			_door_lock_entry.hide()
	else:
		_state = State.LOCKPICK_INTRO
		zoom_views_root.hide()
		_items_root.hide()
		_hud_panel.hide()

# ==================== ItemDetail 拦截 ====================
func _on_detail_opened(item_id: String) -> void:
	_open_record_btn.visible = false
	match item_id:
		"13":  # 青蛙缸 — 播放青蛙叫音效
			_play_sfx(load("res://Audio/SFX/青蛙叫.mp3"))
		"3":
			# 录音笔：探索阶段或录音完成后均显示「打开录音」按钮（播放中除外）
			if _state == State.EXPLORE or _state >= State.TRANSCRIPT_DONE:
				_open_record_btn.visible = true

func _on_item_detail_closed() -> void:
	_open_record_btn.visible = false
	if _state == State.LOCKPICK_INTRO:
		_state = State.LOCKPICK_READY

# ==================== 门锁点击处理 ====================
func _on_door_lock_clicked() -> void:
	match _state:
		State.LOCKPICK_INTRO:
			_show_lockpick_intro()
		State.LOCKPICK_READY:
			_start_lockpick_game()


func _show_lockpick_intro() -> void:
	item_detail.show_detail(
		null,
		"不是四点见面吗？门怎么锁着。先想办法进去吧，还好我还会些开锁的办法。",
		"",
		false,
		"lockpick_intro"
	)


func _start_lockpick_game() -> void:
	if not _lockpick_minigame:
		push_warning("chapter2.gd: LockpickMinigame 节点为空，无法启动小游戏")
		return
	_state = State.LOCKPICK_GAME
	_lockpick_minigame.show()
	_lockpick_minigame.start()


func _on_lockpick_success() -> void:
	if _lockpick_minigame:
		_lockpick_minigame.hide()
	if _door_lock_entry:
		_door_lock_entry.hide()
	GameStateManager.set_record("ch2_lockpick_done", "true")
	_state = State.EXPLORE
	zoom_views_root.show()
	for area in zoom_views_root.get_children():
		area.show()
	_items_root.show()
	_hud_panel.show()


func _on_lockpick_failed() -> void:
	# 失败后自动重置并重新开始小游戏
	if _lockpick_minigame:
		_lockpick_minigame.start()


# ==================== 本地按钮：录音笔「打开录音」====================
func _on_open_record_pressed() -> void:
	item_detail.close_detail()
	if _recording_done:
		# 已解锁：保存当前状态后直接重播
		_state_before_replay = _state
		_state = State.RECORD_PLAYING
		if _hud_panel:
			_hud_panel.hide()
		_record_player.start_playback(_record_audio)
	else:
		_password_panel.open()

# ==================== 密码解锁 → 播放录音 ====================
func _on_password_correct() -> void:
	_password_panel.close()
	_state = State.RECORD_PLAYING
	# 隐藏 HUD，避免遮挡 RecordPlayer 的 Back 按钮
	if _hud_panel:
		_hud_panel.hide()
	_record_player.start_playback(_record_audio)

func _on_record_playback_done() -> void:
	if not _recording_done:
		# 第一次播放完成：解锁物品栏入库
		_recording_done = true
		item_detail.no_auto_inventory_ids.erase("3")
		var voice_node = get_node_or_null("ZoomViews/ClickableArea_Desk/Zoomview_Desk/Items/Voice")
		if voice_node:
			GameStateManager.add_inventory_item("3", voice_node.item_name, voice_node.description, voice_node.detail_image)
		_state = State.TRANSCRIPT_DONE
	else:
		# 重播完成：恢复之前的状态
		_state = _state_before_replay
	if _hud_panel:
		_hud_panel.show()

# ==================== InferencePanel 信号延迟连接 ====================
func _connect_inference_panel() -> void:
	if inference_panel and inference_panel.has_signal("chapter_next_requested"):
		if not inference_panel.inference_success.is_connected(inference_panel.show_completion_buttons):
			inference_panel.inference_success.connect(inference_panel.show_completion_buttons)
		if not inference_panel.chapter_next_requested.is_connected(_on_inference_complete):
			inference_panel.chapter_next_requested.connect(_on_inference_complete)

# ==================== InferencePanel 完成 → 启动结局第一段 ====================
func _on_inference_complete() -> void:
	_state = State.ENDING_PART1
	inference_panel.close_panel()
	# 接管 DialogueManager advance，拦截 __puzzle__ 节点
	DialogueManager.advance_interceptor = _on_dialogue_advance_intercept
	DialogueManager.dialogue_finished.connect(_on_ending_part2_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch2Ending.DATA, "start")

# ==================== 对话推进拦截：捕获 __puzzle__ ====================
func _on_dialogue_advance_intercept(next_id: String) -> bool:
	"""返回 true 表示已拦截（DialogueManager 不继续推进）"""
	if next_id == "__puzzle__":
		_state = State.PUZZLE2
		DialogueManager.pause_dialogue()
		_puzzle_ui.show()
		register_panel_open(_puzzle_ui)
		return true
	return false

# ==================== UI/1 推理板完成（对话中途）====================
func _on_puzzle2_solved() -> void:
	_puzzle_ui.hide()
	_state = State.ENDING_PART2
	DialogueManager.resume_dialogue("post_puzzle")

# ==================== 结局第二段结束 → 完成章节 ====================
func _on_ending_part2_finished() -> void:
	DialogueManager.advance_interceptor = Callable()
	GameStateManager.complete_chapter(2)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
