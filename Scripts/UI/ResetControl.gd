class_name ResetControl
extends Control

@export var level: Level
@export var reset_button: TextureButton

func _ready() -> void:
    reset_button.pressed.connect(on_reset_pressed)

func on_reset_pressed() -> void:
    level.reset_level()