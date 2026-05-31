extends Control

# ==================== 信号 ====================
## 点击 back 按钮时发出，由 Desktop.gd 监听以返回桌面图标视图
signal back_pressed

# ==================== 可配置项 ====================
## 五年转账记录叠加图（在 Inspector 中按顺序拖入，依次对应 46~50 年）
@export var year_46_image: Texture2D
@export var year_47_image: Texture2D
@export var year_48_image: Texture2D
@export var year_49_image: Texture2D
@export var year_50_image: Texture2D

# ==================== 节点引用 ====================
## 叠加在底图上方的年份记录图片（初始隐藏）
@onready var overlay_image: TextureRect = $OverlayImage

## back 按钮，返回桌面
@onready var back_button: TextureButton = $back/TextureButton

## 五个年份切换按钮（顺序：46、47、48、49、50）
@onready var year_buttons: Array = [
	$YearButtons/Year46,
	$YearButtons/Year47,
	$YearButtons/Year48,
	$YearButtons/Year49,
	$YearButtons/Year50,
]

# ==================== 私有变量 ====================
var _year_textures: Array[Texture2D]
## 当前显示的年份索引（-1 表示未选中）
var _current_year: int = -1


# ==================== 初始化 ====================
func _ready() -> void:
	_year_textures = [year_46_image, year_47_image, year_48_image, year_49_image, year_50_image]
	back_button.pressed.connect(_on_back_pressed)
	for i in year_buttons.size():
		var idx := i
		year_buttons[i].pressed.connect(func(): _on_year_button_pressed(idx))
	overlay_image.hide()


# ==================== 事件处理 ====================
func _on_year_button_pressed(idx: int) -> void:
	"""点击年份按钮：若当前已显示同一年份则隐藏（切换），否则切换到新年份"""
	if _current_year == idx:
		overlay_image.hide()
		_current_year = -1
		return
	var tex: Texture2D = _year_textures[idx]
	if tex:
		overlay_image.texture = tex
		overlay_image.show()
		_current_year = idx
	else:
		push_warning("[BankingRecords.gd] 第 %d 个年份图片未设置，请在 Inspector 中拖入" % (idx + 46))


func _on_back_pressed() -> void:
	overlay_image.hide()
	_current_year = -1
	back_pressed.emit()
