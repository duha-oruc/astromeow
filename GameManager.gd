extends Node

signal stats_updated
signal game_over(won: bool, reason: String)

# Phase 1: Ship Prep Tasks
var tasks = {
	"polyethylene": false, # Radiation shielding bricks
	"space_food": false,   # Rations
	"mli": false           # Multi-Layer Insulation
}

# Timer / Mission Readiness Counter
var mission_timer: float = 60.0
var is_timer_running: bool = true
var current_phase: String = "SHIP" # "SHIP" or "MOON"

# Phase 2: Moon Rock Collection
var target_rocks = {
	"Basalt": 3,
	"Anorthosite": 2
}
var collected_rocks = {
	"Basalt": 0,
	"Anorthosite": 0
}

func _process(delta: float) -> void:
	if is_timer_running and current_phase == "SHIP":
		mission_timer -= delta
		emit_signal("stats_updated")
		
		if mission_timer <= 0:
			mission_timer = 0
			is_timer_running = false
			emit_signal("game_over", false, "Time ran out before launch preparations were finished!")

func complete_task(task_name: String) -> void:
	if tasks.has(task_name) and not tasks[task_name]:
		tasks[task_name] = true
		emit_signal("stats_updated")

func all_tasks_done() -> bool:
	return tasks["polyethylene"] and tasks["space_food"] and tasks["mli"]

func collect_rock(rock_type: String) -> void:
	if collected_rocks.has(rock_type):
		collected_rocks[rock_type] += 1
		emit_signal("stats_updated")
		check_moon_win_condition()

func check_moon_win_condition() -> void:
	var won = true
	for rock in target_rocks:
		if collected_rocks[rock] < target_rocks[rock]:
			won = false
			break
	if won:
		emit_signal("game_over", true, "Mission Accomplished! AstroCat collected all lunar samples!")
