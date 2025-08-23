class_name Station
extends Area2D

@warning_ignore("unused_signal")
signal send_score(value: int)

@export var station_data: StationData

@onready var sprite: Sprite2D = $Sprite

var station_grid_snap: Vector2
var floor_tilemap: TileMapLayer

func _ready() -> void:
	body_entered.connect(on_body_enter)

	if station_data != null:
		if station_data.require_box:
			sprite.texture = station_data.texture
			sprite.region_rect = station_data.region

	floor_tilemap = get_tree().get_first_node_in_group("FloorTileMap")
	if floor_tilemap == null:
		print("Floor tilemap tidak ada")
		return
	
	station_grid_snap = floor_tilemap.local_to_map(position)
	var center_of_cell = floor_tilemap.map_to_local(station_grid_snap)
	
	position = center_of_cell

func on_body_enter(body: Node2D) -> void:
	if body.is_in_group("Boxes"):
		if station_data != null:
			if station_data.require_box and (body.box_type == station_data.box_type):
				# print("box masuk type : " + station_data.box_type)
				send_score.emit(1)

		else:
			send_score.emit(1)
			
		
