extends Control

const SETTINGS_PATH := "user://audio_settings.cfg"
const BGM_BUS := "BGM"
const SFX_BUS := "SFX"

@onready var bgm_slider: HSlider = $Center/Panel/Margin/MainVBox/Content/BgmSection/BgmMargin/BgmStack/ValueRow/BgmSlider
@onready var sfx_slider: HSlider = $Center/Panel/Margin/MainVBox/Content/SfxSection/SfxMargin/SfxStack/ValueRow/SfxSlider
@onready var bgm_value_label: Label = $Center/Panel/Margin/MainVBox/Content/BgmSection/BgmMargin/BgmStack/ValueRow/BgmValue
@onready var sfx_value_label: Label = $Center/Panel/Margin/MainVBox/Content/SfxSection/SfxMargin/SfxStack/ValueRow/SfxValue
@onready var status_label: Label = $Center/Panel/Margin/MainVBox/FooterRow/StatusLabel
@onready var close_button = $Center/Panel/Margin/MainVBox/FooterRow/CloseButton2/TextureButton
@onready var reset_button= $Center/Panel/Margin/MainVBox/FooterRow/ResetButton2/TextureButton

var _updating_from_state: bool = false


func _ready() -> void:
	if bgm_slider:
		bgm_slider.min_value = 0.0
		bgm_slider.max_value = 100.0
		bgm_slider.step = 1.0
		bgm_slider.value_changed.connect(_on_bgm_slider_changed)
		bgm_slider.value = 60.0
	if sfx_slider:
		sfx_slider.min_value = 0.0
		sfx_slider.max_value = 100.0
		sfx_slider.step = 1.0
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
		sfx_slider.value = 60.0
	if close_button:
		close_button.pressed.connect(hide)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

	_load_settings()
	_apply_bus_from_sliders()
	_update_value_labels()
	_update_status("音量已加载")


func open_panel() -> void:
	show()
	move_to_front()


func close_panel() -> void:
	hide()


func _on_bgm_slider_changed(_value: float) -> void:
	if _updating_from_state:
		return
	_apply_bus_from_sliders()
	_update_value_labels()
	_save_settings()
	_update_status("已调整 BGM 音量")


func _on_sfx_slider_changed(_value: float) -> void:
	if _updating_from_state:
		return
	_apply_bus_from_sliders()
	_update_value_labels()
	_save_settings()
	_update_status("已调整音效音量")


func _on_reset_pressed() -> void:
	_set_slider_value(bgm_slider, 60.0)
	_set_slider_value(sfx_slider, 60.0)
	_apply_bus_from_sliders()
	_update_value_labels()
	_save_settings()
	_update_status("已恢复默认音量")


func _apply_bus_from_sliders() -> void:
	_set_bus_volume(BGM_BUS, bgm_slider.value if bgm_slider else 80.0)
	_set_bus_volume(SFX_BUS, sfx_slider.value if sfx_slider else 80.0)


func _set_bus_volume(bus_name: String, percent_value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	var clamped_percent := clampf(percent_value, 0.0, 100.0)
	var volume_db := -80.0 if clamped_percent <= 0.0 else linear_to_db(clamped_percent / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _set_slider_value(slider: HSlider, value: float) -> void:
	if slider == null:
		return
	_updating_from_state = true
	slider.value = value
	_updating_from_state = false


func _update_value_labels() -> void:
	if bgm_value_label:
		bgm_value_label.text = "%d%%" % int(round(bgm_slider.value if bgm_slider else 0.0))
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % int(round(sfx_slider.value if sfx_slider else 0.0))


func _update_status(text: String) -> void:
	if status_label:
		status_label.text = text


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "bgm_volume", bgm_slider.value if bgm_slider else 80.0)
	config.set_value("audio", "sfx_volume", sfx_slider.value if sfx_slider else 80.0)
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		_set_slider_value(bgm_slider, 60.0)
		_set_slider_value(sfx_slider, 60.0)
		return

	_set_slider_value(bgm_slider, float(config.get_value("audio", "bgm_volume", 60.0)))
	_set_slider_value(sfx_slider, float(config.get_value("audio", "sfx_volume", 60.0)))
