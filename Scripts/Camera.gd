class_name CameraCenter
extends Camera2D


func _ready() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	
	self.position = viewport_size / 2.0