class_name Box
extends CharacterBody2D

@export var box_data: BoxData
@onready var sprite: Sprite2D = $Sprite2D

var floor_tilemap: TileMapLayer
var box_grid_snap: Vector2
var target_position: Vector2
var moving: bool = false
var move_speed: float = 200.0
var box_type: String

func _ready() -> void:
	if box_data != null:
		box_type = box_data.box_id
		sprite.texture = box_data.texture
		sprite.region_enabled = true
		sprite.region_rect = box_data.region

	add_to_group("Boxes")

	floor_tilemap = get_tree().get_first_node_in_group("FloorTileMap")
	# print("floor tilemap: " + str(floor_tilemap))
	if floor_tilemap == null:
		print("tilemap tidak ada")
		return

	box_grid_snap = floor_tilemap.local_to_map(position)
	# print("box_grid_snap : " + str(box_grid_snap))

	var center_of_cell := floor_tilemap.map_to_local(box_grid_snap)

	position = center_of_cell
	target_position = position

func _process(delta: float) -> void:
	if moving:
		position = position.move_toward(target_position, move_speed * delta)
		if position.distance_to(target_position) < 1.0:
			position = target_position
			moving = false

func set_target_position(new_target: Vector2) -> void:
	target_position = new_target
	moving = true
