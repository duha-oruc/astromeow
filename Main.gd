extends Node2D

func load_moon_surface() -> void:
	if has_node("ShipInterior"):
		$ShipInterior.queue_free()
	
	var moon_scene = preload("res://MoonSurface.tscn").instantiate()
	add_child(moon_scene)
	move_child(moon_scene, 0)
