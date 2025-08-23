class_name Player
extends CharacterBody2D

@warning_ignore("unused_signal")
signal request_move(direction: Vector2i)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var rows: int = 1
var cols: int = 1

var grid_pos: Vector2i
var tile_size: int = 128

## set posisi pertama dari karakter dan atu kondisi ketika posisi player diluar grid maka error
var initial_grid_pos: Vector2i = Vector2.ZERO:
	set(value):
		if (value.x < 0 or value.x >= cols or value.y < 0 or value.y >= rows):
			push_error("Invalid initial position")
			return
		
		initial_grid_pos = value
		grid_pos = value
		position = (Vector2i(grid_pos) + Vector2i.ONE * 1/2) * tile_size 


const MAX_INPUT_DELAY: float = 0.35
var input_delay: float = 0

## digunakan untuk stacking input yang di inputkan oleh pemain
var input_queue: Array[Vector2i] = []

var tween_playing: bool = false


func _ready() -> void:
	position = (Vector2i(grid_pos) + Vector2i.ONE * 1/2) * tile_size
	# print("player pos : " + str(position)) 


func _process(delta: float) -> void:
	if (input_delay <= 0):
		if Input.is_action_pressed("up"):
			try_to_push_queue(Vector2i.UP)
		elif Input.is_action_pressed("down"):
			try_to_push_queue(Vector2i.DOWN)
		elif Input.is_action_pressed("left"):
			try_to_push_queue(Vector2i.LEFT)
		elif Input.is_action_pressed("right"):
			try_to_push_queue(Vector2i.RIGHT)
	else:
		input_delay -= delta
	
	if !input_queue.is_empty():
		try_move()

func try_move() -> void:
	if tween_playing:
		return
	
	var direction: Vector2i = input_queue.pop_front()
	request_move.emit(direction)

func move(new_pos: Vector2i) -> void:
	var direction: Vector2i = new_pos - grid_pos
	
	grid_pos += direction
	var target_position: Vector2 = (Vector2i(grid_pos) + Vector2i.ONE * 1/2) * tile_size
	
	tween_playing = true
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(on_tween_finished)

	change_animation(direction)

func on_tween_finished() -> void:
	tween_playing = false
	animated_sprite_2d.stop()


func change_animation(direction: Vector2i) -> void:
	match direction:
		Vector2i.UP:
			animated_sprite_2d.play("walk_up")
		Vector2i.DOWN:
			animated_sprite_2d.play("walk_down")
		Vector2i.LEFT:
			animated_sprite_2d.play("walk_left")
		Vector2i.RIGHT:
			animated_sprite_2d.play("walk_right")

func try_to_push_queue(direction: Vector2i) -> void:
	if input_queue.size() >= 1:
		return
	
	input_delay = MAX_INPUT_DELAY
	input_queue.push_back(direction)