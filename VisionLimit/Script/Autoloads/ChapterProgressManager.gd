# ChapterProgressManager.gd (Autoload)
extends Node

var unlocked_chapters: Dictionary = {
	1: true,  # 第一章始终解锁
	2: false,
	3: false,
	4: false,
	5: false,
	6: false,
	7: false
}

func is_chapter_unlocked(chapter_index: int) -> bool:
	return unlocked_chapters.get(chapter_index, false)

func unlock_chapter(chapter_index: int) -> void:
	unlocked_chapters[chapter_index] = true
	chapter_unlocked.emit(chapter_index)

signal chapter_unlocked(chapter_index: int)
