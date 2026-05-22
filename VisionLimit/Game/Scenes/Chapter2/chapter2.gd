extends "res://Script/Chapters/chapter.gd"

# ==================== 状态机 ====================
enum State {
	EXPLORE,          # 初始探索（录音密码未解开）
	RECORD_PLAYING,   # RecordPlayer 面板播放中
	TRANSCRIPT_DONE,  # 录音播放完毕，可与魏江对话进入拼图
	PUZZLE,           # 拼图推理阶段（UILayer/1 打开）
	ENDING,           # 最终对话序列
}

var _state := State.EXPLORE

# ==================== 额外节点引用（章节特有）====================
@onready var _password_panel  = $UILayer/PasswordPanel
@onready var _record_audio: AudioStreamPlayer2D = $UILayer/RecordAudio
@onready var _puzzle_ui       = $"UILayer/1"
@onready var _hud_panel       = $UILayer/HudPanel
@onready var _open_record_btn: Node = $"UILayer/ItemDetail/Control/OpenRecordButton"

# ==================== 对话数据 ====================
const Ch2WeijianExit = preload("res://Script/Dialogues/ch2_weijian_exit.gd")
const Ch2Ending      = preload("res://Script/Dialogues/ch2_ending.gd")
const RECORD_PLAYER_SCENE = preload("res://Game/UI/RecordPlayer/RecordPlayer.tscn")

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
