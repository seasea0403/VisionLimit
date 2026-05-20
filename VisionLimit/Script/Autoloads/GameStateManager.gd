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
func is_chapter_unlocked(_chapter_index: int) -> bool:
    # 试玩版本：所有章节默认解锁
    return true

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