extends Control

enum State { ICONS, BROWSER, PASSWORD, BANKING_RECORDS, ADVERTISEMENT }

@export var password_panel_scene: PackedScene
@export var advertisement_scene: PackedScene = preload("res://Game/UI/LeadingPanel/LeadingPanel.tscn")
@export_multiline var advertisement_reaction: String = "海芯的广告如今到处都是。记忆外包嘛，早就不稀罕了。不过也确实有用，没它，我还不知道靠什么谋生呢。"
@export_multiline var advertisement_record: String = "海芯是记忆数字化技术商用化后的微型颅内神经芯片。它在海马体旁侧建立可读写的神经扩展区域，俗称“记忆海”。外部数据可以写入其中，随时提取，永不退化。如今发达城市的海芯持有率已超过70%，教育、医疗、法律与工程等行业也随之改变。"
const ADVERTISEMENT_RECORD_ID: String = "ch1_haixin"

@onready var desktop_icons: Control = $DesktopIcons
@onready var browser_icon: TextureButton = $DesktopIcons/BrowserIcon
@onready var banking_icon: TextureButton = $DesktopIcons/BankingIcon
@onready var browser_view: Control = $BrowserView
@onready var banking_records: Control = $BankingRecords
@onready var ad_overlay: Control = $AdOverlay

var _state: State = State.ICONS
var _unlocked: bool = false
var _password_instance: Control
var _ad_player: Control
var _reaction_detail: Control
var _reaction_z_index: int
var _hud: CanvasItem
var _hud_before_ad: bool = true


func _ready() -> void:
	_hud = get_parent().get_node_or_null("HudPanel") as CanvasItem
	$back.hide()
	browser_icon.pressed.connect(_on_browser_pressed)
	banking_icon.pressed.connect(_on_banking_pressed)
	browser_view.get_node("back/TextureButton").pressed.connect(_show_desktop)
	$BrowserView/BrowserImage/Advertisement.pressed.connect(_on_advertisement_pressed)
	banking_records.back_pressed.connect(_show_desktop)
	ad_overlay.hide()
	if visible:
		_open_computer()
	else:
		_show_desktop()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_node_ready():
		if visible:
			_open_computer()
		else:
			_cancel_advertisement()
			if is_instance_valid(_password_instance):
				_password_instance.hide()


func _open_computer() -> void:
	if _unlocked:
		_show_desktop()
	else:
		_show_password()


func close_panel() -> void:
	hide()
	if is_instance_valid(_hud):
		_hud.show()


func _show_desktop() -> void:
	_state = State.ICONS
	desktop_icons.show()
	browser_view.hide()
	banking_records.hide()
	if is_instance_valid(_password_instance):
		_password_instance.hide()


func _show_password() -> void:
	_state = State.PASSWORD
	desktop_icons.hide()
	browser_view.hide()
	banking_records.hide()
	if not is_instance_valid(_password_instance):
		if not password_panel_scene:
			push_warning("[Desktop] 未设置电脑密码场景")
			close_panel()
			return
		_password_instance = password_panel_scene.instantiate() as Control
		add_child(_password_instance)
		_password_instance.get_node("back/TextureButton").pressed.connect(close_panel)
		_password_instance.get_node("password_1").password_confirmed.connect(_on_password_confirmed)
	_password_instance.show()
	_password_instance.get_node("password_1").password_panel.open()
	if is_instance_valid(_hud):
		_hud.hide()


func _on_password_confirmed() -> void:
	_unlocked = true
	_show_desktop()
	if is_instance_valid(_hud):
		_hud.show()


func _on_browser_pressed() -> void:
	if not _unlocked:
		return
	_state = State.BROWSER
	desktop_icons.hide()
	browser_view.show()


func _on_banking_pressed() -> void:
	if not _unlocked:
		return
	_state = State.BANKING_RECORDS
	desktop_icons.hide()
	banking_records.show()


func _on_advertisement_pressed() -> void:
	if _state != State.BROWSER or is_instance_valid(_ad_player) or is_instance_valid(_reaction_detail):
		return
	_state = State.ADVERTISEMENT
	_hud_before_ad = _hud.visible if is_instance_valid(_hud) else true
	if is_instance_valid(_hud):
		_hud.hide()
	ad_overlay.show()
	# 按浏览器屏幕的位置和尺寸播放，保留电脑边框；内部仍用1920×1080排版。
	var screen: TextureRect = $BrowserView/BrowserImage
	var host: Control = $AdOverlay/Screen
	host.position = screen.position
	host.size = screen.size * screen.scale
	_ad_player = advertisement_scene.instantiate() as Control
	_ad_player.autoplay = false
	_ad_player.manage_hud = false
	host.add_child(_ad_player)
	_ad_player.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_ad_player.size = Vector2(1920, 1080)
	_ad_player.scale = host.size / _ad_player.size
	_ad_player.intro_finished.connect(_on_advertisement_finished, CONNECT_ONE_SHOT)
	_ad_player.play()


func _on_advertisement_finished() -> void:
	_ad_player.queue_free()
	_ad_player = null
	ad_overlay.hide()
	_state = State.BROWSER
	_reaction_detail = get_parent().get_node_or_null("ItemDetail") as Control
	if not _reaction_detail:
		_restore_hud()
		return
	_reaction_z_index = _reaction_detail.z_index
	_reaction_detail.panel_closed.connect(_on_reaction_closed, CONNECT_ONE_SHOT)
	_reaction_detail.z_index = 30
	_reaction_detail.title_label.show()
	_reaction_detail.set_dark_background_visible(true)
	_reaction_detail.show_detail(
		null, advertisement_reaction, "海芯", true, ADVERTISEMENT_RECORD_ID,
		Vector2.ONE, Vector2.ZERO, "海芯", advertisement_record
	)


func _on_reaction_closed() -> void:
	_reaction_detail.z_index = _reaction_z_index
	_reaction_detail = null
	_restore_hud()


func _restore_hud() -> void:
	if is_instance_valid(_hud):
		_hud.visible = _hud_before_ad


func _cancel_advertisement() -> void:
	if is_instance_valid(_ad_player):
		_ad_player.queue_free()
		_ad_player = null
		ad_overlay.hide()
		_restore_hud()
	if is_instance_valid(_reaction_detail):
		_reaction_detail.close_detail()
