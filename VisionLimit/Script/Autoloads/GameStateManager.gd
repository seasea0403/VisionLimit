extends Node

# 记录当前解锁的最高章节
var current_unlocked_chapter: int = 1  # 从第1章开始解锁
var total_chapters: int = 7

func _ready():
	# 添加为 Autoload，这样全局都能访问
	name = "GameStateManager"
	load_progress()  # 恢复上次保存的解锁进度

# 解锁下一章
func unlock_next_chapter() -> void:
	if current_unlocked_chapter < total_chapters:
		current_unlocked_chapter += 1
		print("解锁第 %d 章" % current_unlocked_chapter)
		save_progress()

# 检查某章是否解锁
func is_chapter_unlocked(chapter_index: int) -> bool:
	return chapter_index <= current_unlocked_chapter

# 进入章节（完成后调用这个来解锁下一章）
func complete_chapter(chapter_index: int) -> void:
	if chapter_index == current_unlocked_chapter:
		unlock_next_chapter()
	save_progress()

# 保存进度（可选，如果要持久化）
func save_progress() -> void:
	# 这里可以用 FileAccess 保存到本地文件
	var config = ConfigFile.new()
	config.set_value("progress", "unlocked_chapter", current_unlocked_chapter)
	config.save("user://game_progress.cfg")

# 加载进度
func load_progress() -> void:
	var config = ConfigFile.new()
	var error = config.load("user://game_progress.cfg")
	if error == OK:
		current_unlocked_chapter = config.get_value("progress", "unlocked_chapter", 1)
		print("加载进度：已解锁第 %d 章" % current_unlocked_chapter)


# ==================== 线索收集 ====================
var _collected_clues: Dictionary = {}

func set_clue(clue_id: String) -> void:
	"""标记某条线索已被收集，用于解锁对话中的条件选项"""
	_collected_clues[clue_id] = true

func has_clue(clue_id: String) -> bool:
	"""检查某条线索是否已被收集"""
	return _collected_clues.get(clue_id, false)


# ==================== 剧情选择记录 ====================
var _story_records: Dictionary = {}

func set_record(record_key: String, record_value: String) -> void:
	"""记录玩家在对话中做出的选择"""
	_story_records[record_key] = record_value

func get_record(record_key: String, default_value: String = "") -> String:
	"""读取某个剧情选择的结果"""
	return _story_records.get(record_key, default_value)


# ==================== 词条收集（跨章节持久化）====================
# 记录册 RecordPanel 中显示的词条，按 key 索引，value = { "title": String, "description": String }
var _record_entries: Dictionary = {}

func add_record_entry(entry_key: String, entry_title: String, entry_description: String) -> void:
	"""收集一条记录册词条，跨章节持久保存"""
	var key := entry_key.strip_edges()
	if key.is_empty():
		key = entry_title.strip_edges()
	if key.is_empty():
		return
	var title := entry_title.strip_edges()
	if title.is_empty():
		title = key
	_record_entries[key] = {
		"title": title,
		"description": entry_description.strip_edges()
	}

func get_record_entries() -> Dictionary:
	"""返回当前已收集的所有词条字典（按 key → {title, description}）"""
	return _record_entries

func has_record_entry(entry_key: String) -> bool:
	return _record_entries.has(entry_key)


# ==================== 全局持续音乐（跨场景不中断）====================
var _global_music: AudioStreamPlayer = null
var _global_music_tween: Tween = null

## 当结局音乐激活时为 true，UIPanel 等场景据此屏蔽自身音乐
var is_ending_music_active: bool = false

func _ensure_global_music_player() -> void:
	"""确保全局音乐播放器存在并绑定到 BGM 总线"""
	if _global_music == null:
		_global_music = AudioStreamPlayer.new()
		_global_music.bus = "BGM"
		add_child(_global_music)
	if _global_music.bus != "BGM":
		_global_music.bus = "BGM"

func play_global_music(stream: AudioStream, volume_db: float = 0.0) -> void:
	"""在 Autoload 上立即播放音乐，场景切换后仍保持播放"""
	_ensure_global_music_player()
	if _global_music_tween:
		_global_music_tween.kill()
		_global_music_tween = null
	_global_music.stream = stream
	_global_music.volume_db = volume_db
	_global_music.play()
	is_ending_music_active = true

func fade_in_global_music(stream: AudioStream, duration: float = 1.5, target_volume_db: float = 0.0) -> void:
	"""淡入方式开始播放全局音乐，挂载到 BGM 总线，受 BGM 音量调节控制"""
	_ensure_global_music_player()
	if _global_music_tween:
		_global_music_tween.kill()
	_global_music.stream = stream
	_global_music.volume_db = -80.0
	_global_music.play()
	is_ending_music_active = true
	_global_music_tween = create_tween()
	_global_music_tween.tween_property(_global_music, "volume_db", target_volume_db, duration)

func stop_global_music() -> void:
	"""停止全局音乐并清除激活标记"""
	if _global_music_tween:
		_global_music_tween.kill()
		_global_music_tween = null
	if _global_music != null:
		_global_music.stop()
	is_ending_music_active = false
