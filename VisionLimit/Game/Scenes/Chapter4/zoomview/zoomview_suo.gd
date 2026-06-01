extends "res://Script/Components/zoomview.gd"

# ==================== 状态 ====================
## 密码谜题是否已解开（重进章节时重置）
var _puzzle_solved: bool = false

# ==================== 子节点引用 ====================
@onready var _password_panel: Control = $Items/PasswordPanel
@onready var _things1: Area2D = $Items/things1

# ==================== 初始化 ====================
func _ready() -> void:
	super._ready()
	# 谜题未解时，信件隐藏且不可点击
	_things1.hide()
	_things1.input_pickable = false
	# 连接密码正确信号
	if _password_panel:
		_password_panel.password_correct.connect(_on_password_correct)


# ==================== 覆盖 show_view ====================
func show_view() -> void:
	print("Zoomview_suo: show_view called, solved=", _puzzle_solved)
	if _puzzle_solved:
		# 谜题已解：跳过 Zoomview，直接打开 ItemDetail 展示 things1
		var chapter := _find_chapter()
		if chapter:
			var detail = chapter.get("item_detail")
			print("Zoomview_suo: detail node found: ", detail != null)
			if detail and detail.has_method("show_detail"):
				print("Zoomview_suo: showing detail for item_id: ", _things1.item_id)
				detail.show_detail(
					_things1.detail_image,
					_things1.description,
					_things1.item_name,
					_things1.can_record,
					_things1.item_id,
					_things1.detail_image_scale,
					_things1.detail_image_offset,
					_things1.record_entry_title,
					_things1.record_entry_description
				)
		return

	# 谜题未解：显示 Zoomview，仅显示 PasswordPanel
	print("Zoomview_suo: puzzle not solved, opening password panel")
	show()
	_disable_other_area_inputs()
	_password_panel.show()
	_password_panel.open()


# ==================== 密码解锁回调 ====================
func _on_password_correct() -> void:
	print("Zoomview_suo: _on_password_correct received")
	_puzzle_solved = true
	_password_panel.hide()
	_things1.show()
	_things1.input_pickable = true
	
	# 自动触发一次详情显示，让解谜成功的瞬间就有反馈
	show_view()
