class_name GridDraw
extends Node2D

var tile_size: int = 128
var rows: int = 0
var cols: int = 0

var floor_tilemap: TileMapLayer

func _ready() -> void:
	floor_tilemap = get_tree().get_first_node_in_group("FloorTileMap")

	var used_tiles_rect = floor_tilemap.get_used_rect()

	cols = used_tiles_rect.size.x
	rows = used_tiles_rect.size.y

	var tileset = floor_tilemap.tile_set
	if tileset and tileset.get_source_count() > 0:
		var source = tileset.get_source(1)
		if source is TileSetAtlasSource:
			tile_size = source.texture_region_size.x

	queue_redraw()

func _draw() -> void:
	var color: Color = Color(255, 255, 255, 0.35)

	var used_rect = floor_tilemap.get_used_rect()

	var center_pos = floor_tilemap.map_to_local(used_rect.position)
	var start_pos_in_pixel = center_pos - Vector2(tile_size / 2.0, tile_size / 2.0)

	var end_x = start_pos_in_pixel.x + (cols * tile_size)
	var end_y = start_pos_in_pixel.y + (rows * tile_size)

	for i in range(rows + 1):
		var y_pos = start_pos_in_pixel.y + (i * tile_size)
		draw_line(Vector2(start_pos_in_pixel.x, y_pos), Vector2(end_x, y_pos), color, 3)
	
	for i in range(cols + 1):
		var x_pos = start_pos_in_pixel.x + (i * tile_size)
		draw_line(Vector2(x_pos, start_pos_in_pixel.y), Vector2(x_pos, end_y), color, 3)
