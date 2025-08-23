class_name Level
extends Node2D

@export var win_ui: CanvasLayer
@export var reset_ui: CanvasLayer
@export var canvas_modulate: CanvasModulate

var max_stations: int = 0
var stations: Array
var current_score: int = 0

func _ready() -> void:
	get_tree().paused = false
	stations = get_tree().get_nodes_in_group("Stations")

	for station in stations:
		print(station)
		if station is Station:
			station.send_score.connect(on_send_score)
	
	max_stations = stations.size()


func _process(_delta: float) -> void:
	if current_score == max_stations:
		canvas_modulate.show()
		win_ui.show()
		reset_ui.hide()
		get_tree().paused = true
		return


func on_send_score(value: int) -> void:
	current_score += value


func reset_level() -> void:
	get_tree().call_deferred("reload_current_scene")
