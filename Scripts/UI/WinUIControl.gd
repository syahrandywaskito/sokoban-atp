class_name WinUIControl
extends Control

@export var next_scene: PackedScene
@export var level: Level
@export var next_level_button: TextureButton
@export var retry_level_button: TextureButton

func _ready() -> void:
    next_level_button.pressed.connect(on_next_pressed)
    retry_level_button.pressed.connect(on_retry_pressed)

func on_next_pressed() -> void:
    get_tree().call_deferred("change_scene_to_packed", next_scene)

func on_retry_pressed() -> void:
    level.reset_level()
