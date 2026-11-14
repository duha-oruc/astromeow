extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var checklist_label: Label = $ChecklistLabel
@onready var end_panel: Panel = $EndPanel
@onready var end_message: Label = $EndPanel/EndMessage

func _ready() -> void:
	end_panel.visible = false
	GameManager.stats_updated.connect(update_ui)
	GameManager.game_over.connect(_on_game_over)
	update_ui()

func update_ui() -> void:
	if GameManager.current_phase == "SHIP":
		timer_label.text = "Launch Window: %.1fs" % GameManager.mission_timer
		
		var t = GameManager.tasks
		checklist_label.text = "PRE-FLIGHT CHECKLIST:\n"
		checklist_label.text += "[%s] Polyethylene Radiation Bricks\n" % ("X" if t["polyethylene"] else " ")
		checklist_label.text += "[%s] Pack Space Cat Food\n" % ("X" if t["space_food"] else " ")
		checklist_label.text += "[%s] Assemble MLI Shielding\n" % ("X" if t["mli"] else " ")
		if GameManager.all_tasks_done():
			checklist_label.text += "\n>> GO TO COCKPIT TO LAUNCH! <<"
			
	elif GameManager.current_phase == "MOON":
		timer_label.text = "LOCATION: LUNAR SURFACE"
		var c = GameManager.collected_rocks
		var req = GameManager.target_rocks
		checklist_label.text = "COLLECT TARGET SAMPLES:\n"
		checklist_label.text += "Basalt: %d / %d\n" % [c["Basalt"], req["Basalt"]]
		checklist_label.text += "Anorthosite: %d / %d" % [c["Anorthosite"], req["Anorthosite"]]

func _on_game_over(won: bool, reason: String) -> void:
	end_panel.visible = true
	end_message.text = ("VICTORY!\n" if won else "MISSION FAILED!\n") + reason
