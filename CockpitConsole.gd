extends Area2D

func _ready() -> void:
	body_entered.connect(func(b): if b.name == "CatPlayer": b.nearby_interactable = self)
	body_exited.connect(func(b): if b.name == "CatPlayer": b.nearby_interactable = null)

func interact() -> void:
	if GameManager.all_tasks_done():
		GameManager.current_phase = "MOON"
		GameManager.is_timer_running = false
		get_tree().current_scene.load_moon_surface()
	else:
		print("Meow! Finish all pre-flight preparations first!")
