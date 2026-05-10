
extends Node

# ==================== 信号定义 ====================
signal puzzle_solved(puzzle_id)
signal chapter_completed(chapter_num)
signal discovery_added(clue_text)

# ==================== 章节管理 ====================
## 当前所在的章节 (1 = 第一章, 2 = 第二章, ... 7 = 第七章)
var current_chapter: int = 1

## 已解锁的章节列表 (默认只有第一章解锁)
var unlocked_chapters: Array = [1]

## 每章的完成状态 (key: 章节数, value: true/false)
var completed_chapters: Dictionary = {}


# ==================== 谜题进度 ====================
## 每章内的谜题标志 (key: "chapter1_puzzle1", value: true/false)
var puzzle_flags: Dictionary = {}


# ==================== 线索发现 ====================
## 已发现的线索列表 (存储线索描述文本)
var discoveries: Array[String] = []


# ==================== 初始化 ====================
func _ready() -> void:
	# 项目启动时自动调用
	print("GameState 已初始化")


# ==================== 章节管理方法 ====================

## 解锁某一章
func unlock_chapter(chapter_num: int) -> void:
	if chapter_num not in unlocked_chapters:
		unlocked_chapters.append(chapter_num)
		unlocked_chapters.sort()
		print("已解锁第 %d 章" % chapter_num)

## 标记某章为完成
func complete_chapter(chapter_num: int) -> void:
	completed_chapters[chapter_num] = true
	print("第 %d 章已完成" % chapter_num)
	emit_signal("chapter_completed", chapter_num)
	# 自动解锁下一章
	if chapter_num < 7:
		unlock_chapter(chapter_num + 1)

## 检查某章是否已解锁
func is_chapter_unlocked(chapter_num: int) -> bool:
	return chapter_num in unlocked_chapters

## 检查某章是否已完成
func is_chapter_completed(chapter_num: int) -> bool:
	return completed_chapters.get(chapter_num, false)


# ==================== 谜题方法 ====================

## 设置某个谜题的状态
func set_puzzle_flag(puzzle_id: String, solved: bool = true) -> void:
	puzzle_flags[puzzle_id] = solved
	if solved:
		emit_signal("puzzle_solved", puzzle_id)
	print("谜题 %s 已%s" % [puzzle_id, "解开" if solved else "重置"])

## 检查某个谜题是否已解开
func is_puzzle_solved(puzzle_id: String) -> bool:
	return puzzle_flags.get(puzzle_id, false)


# ==================== 线索方法 ====================

## 添加发现的线索 (自动去重)
func add_discovery(clue_text: String) -> void:
	if clue_text not in discoveries:
		discoveries.append(clue_text)
		emit_signal("discovery_added", clue_text)
		print("新发现: %s" % clue_text)
	else:
		print("已有相同线索，跳过")

## 获取所有发现
func get_all_discoveries() -> Array[String]:
	return discoveries

## 清空所有发现 (重新开始游戏时)
func clear_discoveries() -> void:
	discoveries.clear()
	print("所有线索已清空")


# ==================== 重置游戏 ====================

## 重置所有进度 (返回开始界面时调用)
func reset_game() -> void:
	current_chapter = 1
	unlocked_chapters = [1]
	completed_chapters.clear()
	puzzle_flags.clear()
	discoveries.clear()
	print("游戏已重置")