extends Area2D

@export_enum("Basalt", "Anorthosite", "DecoyRock") var rock_type: String = "Basalt"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CatPlayer":
		body.nearby_interactable = self

func _on_body_exited(body: Node2D) -> void:
	if body.name == "CatPlayer" and body.nearby_interactable == self:
		body.nearby_interactable = null

func interact() -> void:
	GameManager.collect_rock(rock_type)
	queue_free()
