extends Area2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		var player = get_parent().get_node_or_null("CatPlayer")
		if player and global_position.distance_to(player.global_position) < 120.0:
			if GameManager.all_tasks_done():
				GameManager.current_phase = "MOON"
				GameManager.is_timer_running = false
				GameManager.emit_signal("stats_updated")
				get_tree().current_scene.load_moon_surface()
			else:
				print("Meow! Finish all pre-flight preparations first!")
