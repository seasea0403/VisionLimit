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

	# 拼图 UI：连接完成信号（字符串形式，避免静态类型检查警告）
	_puzzle_ui.connect("puzzle_solved", _on_puzzle_solved_handler)

	# ItemDetail 信号
	item_detail.detail_opened.connect(_on_detail_opened)
	item_detail.action_pressed.connect(_on_action_pressed)

# ==================== ItemDetail 拦截 ====================
func _on_detail_opened(item_id: String) -> void:
	match item_id:
		"3":
			# 录音笔：EXPLORE 阶段显示"打开录音"动作按钮
			if _state == State.EXPLORE:
				item_detail.set_action_button(true, "打开录音")
		"1":
			# 魏江：录音播放完后拦截 ItemDetail，直接触发对话
			if _state == State.TRANSCRIPT_DONE or _state == State.PUZZLE:
				item_detail.close_detail()
				# 回退到 TRANSCRIPT_DONE 以便对话可重复触发（如玩家中途关闭拼图）
				_state = State.TRANSCRIPT_DONE
				_show_exit_dialogue()

# ==================== 动作按钮（录音笔"打开录音"）====================
func _on_action_pressed() -> void:
	if item_detail.current_item_id == "3" and _state == State.EXPLORE:
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
	_puzzle_ui.hide()
	DialogueManager.dialogue_finished.connect(_on_ending_finished, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(Ch2Ending.DATA, "start")

# ==================== 结局：进入第三章 ====================
func _on_ending_finished() -> void:
	GameStateManager.complete_chapter(2)
	get_tree().change_scene_to_file("res://Game/Scenes/Chapter3/1/chapter_3_1.tscn")
