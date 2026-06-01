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


# ==================== 物品收藏面板（SumPanel）====================
## 按章节存储的物品：{ chapter_num(int): { item_id: { name, description, thumbnail } } }
var _inventory_items_by_chapter: Dictionary = {}
## 当前正在运行的章节编号（由章节场景的 _ready 通过 set_current_chapter 设置）
var _current_chapter: int = 0

## 有新物品加入时发出，携带 item_id
signal item_added_to_inventory(item_id: String)

func set_current_chapter(chapter_num: int) -> void:
	"""进入章节时设置当前章节号，由 chapter.gd 的 _ready 调用"""
	_current_chapter = chapter_num

func get_current_chapter() -> int:
	"""返回当前章节号"""
	return _current_chapter

func reset_chapter_items(chapter_num: int) -> void:
	"""重置某章物品（每次从关卡选择重新开始该章时调用，实现"只保留最后一次游玩"）"""
	_inventory_items_by_chapter[chapter_num] = {}

func add_inventory_item(item_id: String, item_name: String, description: String, thumbnail: Texture2D = null) -> void:
	"""将物品加入当前章节的收藏，相同 item_id 在同一章内不重复添加"""
	if _current_chapter <= 0:
		return
	var key := item_id.strip_edges()
	if key.is_empty():
		return
	if not _inventory_items_by_chapter.has(_current_chapter):
		_inventory_items_by_chapter[_current_chapter] = {}
	if _inventory_items_by_chapter[_current_chapter].has(key):
		return
	_inventory_items_by_chapter[_current_chapter][key] = {
		"name": item_name,
		"description": description,
		"thumbnail": thumbnail,
	}
	item_added_to_inventory.emit(key)

func get_inventory_items() -> Dictionary:
	"""返回当前章节的物品字典（向后兼容接口，InferencePanel 等直接调用此函数仍只看到本章物品）"""
	return get_inventory_items_for_chapter(_current_chapter)

func get_inventory_items_for_chapter(chapter_num: int) -> Dictionary:
	"""返回指定章节的物品字典"""
	if not _inventory_items_by_chapter.has(chapter_num):
		return {}
	return _inventory_items_by_chapter[chapter_num]

func get_unlocked_chapters_with_items() -> Array:
	"""返回已解锁且有物品记录的章节编号列表（升序），供 SumPanel 导航使用"""
	var chapters: Array = []
	for ch in _inventory_items_by_chapter.keys():
		if ch <= current_unlocked_chapter and not _inventory_items_by_chapter[ch].is_empty():
			chapters.append(ch)
	chapters.sort()
	return chapters

func has_inventory_item(item_id: String) -> bool:
	return get_inventory_items_for_chapter(_current_chapter).has(item_id)


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
