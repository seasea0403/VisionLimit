extends Node2D

@export var hover_tint: Color = Color(0.88, 0.88, 0.88, 1.0)
@export var pressed_tint: Color = Color(0.72, 0.72, 0.72, 1.0)

@onready var texture_button: TextureButton = $TextureButton
@onready var click_sfx = $click
@onready var hover_sfx = $hover

var _is_hovered: bool = false
var _is_pressed: bool = false


func _ready() -> void:
	if not texture_button:
		push_warning("UIbutton: 缺少 TextureButton 子节点")
		return

	_sync_button_textures()
	_connect_button_signals()
	_update_button_visual()


func _sync_button_textures() -> void:
	var normal_texture: Texture2D = texture_button.texture_normal
	if not normal_texture:
		push_warning("UIbutton: texture_normal 未配置")
		return

	if not texture_button.texture_hover:
		texture_button.texture_hover = normal_texture
	if not texture_button.texture_pressed:
		texture_button.texture_pressed = normal_texture
	if not texture_button.texture_disabled:
		texture_button.texture_disabled = normal_texture


func _connect_button_signals() -> void:
	texture_button.mouse_entered.connect(_on_mouse_entered)
	texture_button.mouse_exited.connect(_on_mouse_exited)
	texture_button.button_down.connect(_on_button_down)
	texture_button.button_up.connect(_on_button_up)


func _update_button_visual() -> void:
	if _is_pressed:
		texture_button.modulate = pressed_tint
	elif _is_hovered:
		texture_button.modulate = hover_tint
	else:
		texture_button.modulate = Color(1, 1, 1, 1)


func _on_mouse_entered() -> void:
	_is_hovered = true
	hover_sfx.play()
	_update_button_visual()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_is_pressed = false
	_update_button_visual()


func _on_button_down() -> void:
	_is_pressed = true
	click_sfx.play()
	_update_button_visual()


func _on_button_up() -> void:
	_is_pressed = false
	_update_button_visual()
