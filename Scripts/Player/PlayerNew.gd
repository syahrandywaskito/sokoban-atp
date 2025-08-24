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
	var next_grid_pos = player_grid_pos + direction
	var next_to_next_grid_pos = next_grid_pos + direction

	var boxes := get_tree().get_nodes_in_group("Boxes")
	var next_box_node: Node2D = get_box_at_grid(next_grid_pos, boxes)

	var holes := get_tree().get_nodes_in_group("Holes")
	var next_hole_node: Node2D = get_hole_at_grid(next_grid_pos, holes)

	# 1. Periksa apakah ada dinding di depan
	var wall_tile_data : TileData = wall_tilemap.get_cell_tile_data(Vector2i(next_grid_pos))
	if wall_tile_data != null and wall_tile_data.get_custom_data("wall"):
		return

	# 2. Jika ada kotak di depan pemain
	if next_box_node != null:
		var next_to_next_box_node: Node2D = get_box_at_grid(next_to_next_grid_pos, boxes)
		var next_to_next_hole_node: Hole = get_hole_at_grid(next_to_next_grid_pos, holes)
		var next_to_next_wall_data: TileData = wall_tilemap.get_cell_tile_data(Vector2i(next_to_next_grid_pos))

		# Jika tempat di depan kotak kosong atau sudah terisi lubang
		if next_to_next_box_node == null and (next_to_next_wall_data == null or !next_to_next_wall_data.get_custom_data("wall")):
			# Cek apakah ada lubang di depan kotak
			if next_to_next_hole_node != null:
				if !next_to_next_hole_node.filled:
					# Dorong kotak ke lubang kosong
					next_box_node.set_target_position(floor_tilemap.map_to_local(next_to_next_grid_pos))
					# next_to_next_hole_node.fill_hole(next_box_node)
					move_player_to(next_grid_pos)
				else:
					# Lubang sudah terisi, maka kotak bisa lewat
					var next_box_target_pos = floor_tilemap.map_to_local(next_to_next_grid_pos)
					next_box_node.set_target_position(next_box_target_pos)
					move_player_to(next_grid_pos)
			else:
				# Dorong kotak ke tempat kosong
				var next_box_target_pos = floor_tilemap.map_to_local(next_to_next_grid_pos)
				next_box_node.set_target_position(next_box_target_pos)
				move_player_to(next_grid_pos)
		else:
			return
	# 3. Jika ada lubang di depan pemain (tanpa kotak)
	elif next_hole_node != null:
		# Jika lubang belum terisi, pemain tidak bisa bergerak
		if !next_hole_node.filled:
			return
		else:
			# Jika lubang sudah terisi, pemain bisa melewatinya
			move_player_to(next_grid_pos)
	# 4. Jika tidak ada apa-apa, pemain bisa bergerak
	else:
		move_player_to(next_grid_pos)

func change_anim(direction: Vector2) -> void:
	match direction:
		Vector2(0,-1):
			anim.play("walk_up")
		Vector2(0,1):
			anim.play("walk_down")
		Vector2(1,0):
			anim.play("walk_right")
		Vector2(-1,0):
			anim.play("walk_left")

func move_player_to(new_grid_pos: Vector2) -> void:
	player_grid_pos = new_grid_pos
	target_position = floor_tilemap.map_to_local(player_grid_pos)
	moving = true

func get_hole_at_grid(grid_pos: Vector2i, holes: Array) -> Node2D:
	for hole in holes:
		var hole_grid_pos = floor_tilemap.local_to_map(hole.position)
		if hole_grid_pos == grid_pos:
			return hole
	return null

func get_box_at_grid(grid_pos: Vector2i, boxes: Array):
	for box in boxes:
		var box_grid_pos = floor_tilemap.local_to_map(box.position)
		if box_grid_pos == grid_pos:
			return box
	return null
