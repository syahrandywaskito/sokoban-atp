class_name PlayerNew
extends CharacterBody2D

@export var tile_size: int = 128
@export var movement_speed: float = 200
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var target_position: Vector2
var moving: bool = false
var player_grid_pos: Vector2

#tilemap
var floor_tilemap: TileMapLayer
var wall_tilemap: TileMapLayer

func _ready() -> void:
	floor_tilemap = get_tree().get_first_node_in_group("FloorTileMap")
	if floor_tilemap == null:
		push_error("Tilemap node not found in parent scene")
		return

	wall_tilemap = get_tree().get_first_node_in_group("WallTileMap")
	if wall_tilemap == null:
		push_error("Tilemap node not found in parent scene")
		return
	
	player_grid_pos = floor_tilemap.local_to_map(position)
	# print("player grid pos : " + str(player_grid_pos))

	var center_of_cell = floor_tilemap.map_to_local(player_grid_pos)

	position = center_of_cell
	target_position = position
	
func _process(delta: float) -> void:
	
	if moving:
		## menggerakkan posisi pemain ke target di tilemap
		position = position.move_toward(target_position, movement_speed * delta)

		if position.distance_to(target_position) < 1.0:
			position = target_position
			moving = false
	else:
		var direction = Vector2.ZERO
		if Input.is_action_just_pressed("up"):
			direction.y = -1
		elif Input.is_action_just_pressed("down"):
			direction.y = 1
		elif Input.is_action_just_pressed("left"):
			direction.x = -1
		elif Input.is_action_just_pressed("right"):
			direction.x = 1
	
		if direction != Vector2.ZERO:
			# print("direction : " + str(direction))
			check_and_move(direction)
			change_anim(direction)
		else:
			anim.stop()
	
func check_and_move(direction: Vector2) -> void:
	## grid sebelahnya sesuai dengan direction movement
	var next_grid_pos = player_grid_pos + direction

	## dua grid setelahnya sesuai dengan direction movement
	var next_to_next_grid_pos = next_grid_pos + direction

	var wall_tile_data : TileData = wall_tilemap.get_cell_tile_data(Vector2i(next_grid_pos))

	if wall_tile_data != null and wall_tile_data.get_custom_data("wall"):
		return
	
	var boxes := get_tree().get_nodes_in_group("Boxes")
	var next_box_node: Node2D = get_box_at_grid(next_grid_pos, boxes)

	if next_box_node != null:
		var next_to_next_box_node: Node2D = get_box_at_grid(next_to_next_grid_pos, boxes)
		var next_to_next_tile_data: TileData = wall_tilemap.get_cell_tile_data(Vector2i(next_to_next_grid_pos))

		if next_to_next_box_node == null and (next_to_next_tile_data == null or !next_to_next_tile_data.get_custom_data("wall")):
			var next_box_target_pos = floor_tilemap.map_to_local(next_to_next_grid_pos)
			next_box_node.set_target_position(next_box_target_pos)

			move_player_to(next_grid_pos)
		else:
			return
	else:
		move_player_to(next_grid_pos)

func change_anim(direction: Vector2) -> void:
	match direction:
		Vector2(0,-1):
			anim.play("walk_up")
			# print("gerak ke atas")
		Vector2(0,1):
			anim.play("walk_down")
			# print("gerak ke bawah")
		Vector2(1,0):
			anim.play("walk_right")
			# print("gerak ke kanan")
		Vector2(-1,0):
			anim.play("walk_left")
			# print("gerak ke kiri")

func move_player_to(new_grid_pos: Vector2) -> void:
	player_grid_pos = new_grid_pos
	target_position = floor_tilemap.map_to_local(player_grid_pos)
	moving = true

func get_box_at_grid(grid_pos: Vector2i, boxes: Array):
	for box in boxes:
		var box_grid_pos = floor_tilemap.local_to_map(box.position)
		if box_grid_pos == grid_pos:
			return box
	return null
