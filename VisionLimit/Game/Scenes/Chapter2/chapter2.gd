extends "res://Script/Chapters/chapter.gd"

# ==================== 状态机 ====================
enum State {
	LOCKPICK_INTRO,   # 开场：等待第一次点击，显示提示文字
	LOCKPICK_READY,   # 提示已读：等待第二次点击启动小游戏
	LOCKPICK_GAME,    # 开锁小游戏进行中
	EXPLORE,          # 初始探索（录音密码未解开）
	RECORD_PLAYING,   # RecordPlayer 面板播放中
	TRANSCRIPT_DONE,  # 录音播放完毕，可与魏江对话进入拼图
	PUZZLE,           # 拼图推理阶段（UILayer/1 打开）
	ENDING,           # 最终对话序列
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
const Ch2WeijianExit = preload("res://Script/Dialogues/ch2_weijian_exit.gd")
const Ch2Ending      = preload("res://Script/Dialogues/ch2_ending.gd")
const RECORD_PLAYER_SCENE = preload("res://Game/UI/RecordPlayer/RecordPlayer.tscn")

var _lockpick_minigame: Control = null
var _door_lock_entry: Node2D   = null

var _record_player: Control = null

# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()

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

	# 拼图 UI：连接完成信号（字符串形式，避免静态类型检查警告）
	_puzzle_ui.connect("puzzle_solved", _on_puzzle_solved_handler)

	# ItemDetail 信号
	item_detail.detail_opened.connect(_on_detail_opened)
	_open_record_btn.get_node("TextureButton").pressed.connect(_on_open_record_pressed)
	item_detail.panel_closed.connect(_on_item_detail_closed)

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
		"3":
			# 录音笔：EXPLORE 阶段显示「打开录音」按钮
			if _state == State.EXPLORE:
				_open_record_btn.visible = true
		"1":
			# 魏江：录音播放完后拦截 ItemDetail，直接触发对话
			if _state == State.TRANSCRIPT_DONE or _state == State.PUZZLE:
				item_detail.close_detail()
				# 回退到 TRANSCRIPT_DONE 以便对话可重复触发（如玩家中途关闭拼图）
				_state = State.TRANSCRIPT_DONE
				_show_exit_dialogue()

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
	_state = State.TRANSCRIPT_DONE
	if _hud_panel:
		_hud_panel.show()

# ==================== 魏江关卡出口对话 ====================
func _show_exit_dialogue() -> void:
	DialogueManager.dialogue_finished.connect(_on_exit_dialogue_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch2WeijianExit.DATA, "start")

func _on_exit_dialogue_finished() -> void:
	var choice: String = GameStateManager.get_record("ch2_exit_choice", "")
	if choice == "start":
		_state = State.PUZZLE
		_puzzle_ui.show()
		register_panel_open(_puzzle_ui)

# ==================== 拼图完成 ====================
func _on_puzzle_solved_handler() -> void:
	_state = State.ENDING
	# 合成面板保持两秒后再关闭
	await get_tree().create_timer(2.0).timeout
	_puzzle_ui.hide()
	DialogueManager.dialogue_finished.connect(_on_ending_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch2Ending.DATA, "start")

# ==================== 结局：解锁第三章并返回关卡选择 ====================
func _on_ending_finished() -> void:
	GameStateManager.complete_chapter(2)
	SceneTransitionManager.change_scene_to_file("res://Game/UI/ChooseLevelPanel/ChooseLevelPanel.tscn")
