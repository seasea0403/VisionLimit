extends Control

## 证据板·最后整理
## 玩家把前六章收集到的线索拖入对应栏目，整理完成后可关闭面板。

@onready var clue_pool: HFlowContainer = $CluePool
@onready var info_label: Label = $ResultArea/InfoLabel
@onready var action_box: HBoxContainer = $ResultArea/ActionBox
@onready var btn_close: Button = $ResultArea/ActionBox/BtnClose

## 所有线索卡默认全部解锁
const UNLOCK_RULES: Dictionary = {
	# ── 第一栏：污染相关（精炼厂 / 环境）──
	"clue_p1": [],                          # C-03汞超标 ← 默认解锁
	"clue_p2": [],                          # 精炼厂排污 ← 默认解锁
	"clue_p3": [],                          # 正源环境检测公司 ← 默认解锁
	# ── 第二栏：医疗相关（苍屿症 / 病例）──
	"clue_d1": [],                          # 苍屿症 ← 默认解锁
	"clue_d2": [],                          # 郑和平采样坐标 ← 默认解锁
	"clue_d3": [],                          # 儿童病例集中分布 ← 默认解锁
	# ── 第三栏：组织相关（晴野 / 临深）──
	"clue_s1": [],                          # 晴野基金会资金流向 ← 默认解锁
	"clue_s2": [],                          # 临深集团关联关系 ← 默认解锁
	"clue_s3": [],                          # 环保局档案删除节点 ← 默认解锁
}

var _available_count: int = 0
var _placed_count: int = 0
var _status_level: int = -1 # 0=完整 1=较完整 2=不完整
var _decided: bool = false


func _ready() -> void:
	_apply_lock_states()
	_connect_slots()

	info_label.text = ""
	action_box.visible = false

	btn_close.pressed.connect(_on_btn_close_pressed)


## ──────────────── 解锁状态应用 ────────────────

## 遍历 CluePool 下已存在的 9 个 CluePanel（在 .tscn 中静态摆放），
## 根据 UNLOCK_RULES + GameStateManager 决定是否置灰禁拖。
func _apply_lock_states() -> void:
	var gsm: Node = get_node_or_null("/root/GameStateManager")
	_available_count = 0
	for panel in clue_pool.get_children():
		if not (panel is Control):
			continue
		var id: String = ""
		if "clue_id" in panel:
			id = str(panel.get("clue_id"))
		var unlocked: bool = _is_unlocked(id, gsm)
		if unlocked:
			_available_count += 1
			(panel as CanvasItem).modulate = Color(1, 1, 1, 1)
			(panel as Control).mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			(panel as CanvasItem).modulate = Color(0.35, 0.35, 0.35, 1.0)
			(panel as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func _is_unlocked(id: String, gsm: Node) -> bool:
	if not UNLOCK_RULES.has(id):
		return true # 未列入规则的默认解锁，避免误屏蔽
	var sources: Array = UNLOCK_RULES[id]
	if sources.is_empty():
		return true
	if gsm == null or not gsm.has_method("has_clue"):
		return false
	# 任一来源 clue 被收集，即视为本卡片解锁
	for src in sources:
		if gsm.call("has_clue", str(src)):
			return true
	return false


## ──────────────── 槽监听 ────────────────

func _connect_slots() -> void:
	for col_idx in range(3):
		var slots_node: Node = get_node("Columns/Col" + str(col_idx) + "/Slots")
		if slots_node == null:
			continue
		for slot in slots_node.get_children():
			if slot.has_signal("slot_updated"):
				# 把槽引用和列索引绑定进回调，就知道应该属于哪一栏
				slot.slot_updated.connect(_on_slot_updated.bind(slot, col_idx))


func _on_slot_updated(slot: Node, expected_col: int) -> void:
	# slot_updated 在放入和取出时都会触发
	if "held_clue_id" not in slot or slot.held_clue_id == "":
		# 线索被取出，重新计数即可
		_recount_placed()
		return

	# 检查是否放入了正确的栏目
	var actual_col: int = _get_clue_col(str(slot.held_clue_id))
	if actual_col != expected_col:
		# 栏目错误：闪红 + 平静后清除（线索自动回到线索池）
		if slot.has_method("flash_error"):
			slot.flash_error()
		if slot.has_method("clear_slot"):
			# 稍延再清除，让闪红动画能看到
			var t: SceneTreeTimer = get_tree().create_timer(0.5)
			t.timeout.connect(slot.clear_slot)
		return

	_recount_placed()
	if _available_count > 0 and _placed_count >= _available_count:
		_evaluate_state()


## 匹配 clue_id 前缀返回对应列索引
func _get_clue_col(clue_id: String) -> int:
	if clue_id.begins_with("clue_p"):
		return 0
	if clue_id.begins_with("clue_d"):
		return 1
	if clue_id.begins_with("clue_s"):
		return 2
	return -1


## 重新统计已放入线索的数量
func _recount_placed() -> void:
	_placed_count = 0
	for col_idx in range(3):
		var slots_node: Node = get_node("Columns/Col" + str(col_idx) + "/Slots")
		if slots_node == null:
			continue
		for slot in slots_node.get_children():
			if "held_clue_id" in slot and slot.held_clue_id != "":
				_placed_count += 1


## ──────────────── 评级与按钮 ────────────────

func _evaluate_state() -> void:
	if _placed_count >= 9:
		_status_level = 0
		info_label.text = "证据链完整。来源可追溯。"
	elif _placed_count >= 7:
		_status_level = 1
		info_label.text = "证据链较完整。部分来源不可追溯。"
	else:
		_status_level = 2
		info_label.text = "证据链有缺口。可能无法支撑正式指控。"
	info_label.text += "\n\n整理完成。"
	action_box.visible = true


signal panel_completed

func _on_btn_close_pressed() -> void:
	if _decided:
		return
	_decided = true
	action_box.visible = false
	panel_completed.emit()
	queue_free()
