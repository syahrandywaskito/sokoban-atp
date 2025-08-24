class_name Hole
extends Area2D

@export var hole_data: HoleData

@onready var sprite: Sprite2D = $Sprite2D

## hole property 
var filled: bool = false
var already_filled: bool = false

var floor_tilemap: TileMapLayer
var hole_grid_snap: Vector2

func _ready() -> void:
    body_entered.connect(on_hole_filled)

    if hole_data != null:
        if hole_data.requirement_box_type:
            sprite.texture = hole_data.texture
            sprite.region_rect = hole_data.region

    floor_tilemap = get_tree().get_first_node_in_group("FloorTileMap")
    if floor_tilemap == null:
        print("Floor tilemap tidak ada")
        return
    
    hole_grid_snap = floor_tilemap.local_to_map(position)
    var center_of_cell = floor_tilemap.map_to_local(hole_grid_snap)

    position = center_of_cell

func on_hole_filled(body: Node2D) -> void:
    if !already_filled:
        if body.is_in_group("Boxes"):
            if hole_data != null:
                if hole_data.requirement_box_type:
                    if (body.box_type == hole_data.box_type):
                        print("box : " + hole_data.box_type + " masuk")
                        filled = true
                        fill_hole_with_box(body.box_type)
                        body.queue_free()
                        already_filled = true
                else:
                    filled = true
                    fill_hole_with_box(body.box_type)
                    body.queue_free()
                    already_filled = true

func fill_hole_with_box(box_type: String) -> void:
    match box_type:
        "box_coklat":
            sprite.region_rect = hole_data.fill_region[0]
        "box_merah":
            sprite.region_rect = hole_data.fill_region[1]
        "box_biru":
            sprite.region_rect = hole_data.fill_region[2]
        "box_hijau":
            sprite.region_rect = hole_data.fill_region[3]
        "box_abu":
            sprite.region_rect = hole_data.fill_region[4]