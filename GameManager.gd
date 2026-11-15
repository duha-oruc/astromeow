extends Node

signal stats_updated
signal game_over(won: bool, reason: String)
signal nasa_flare_loaded

# --- NASA API VERİLERİ ---
var flare_data = {
	"class_type": "M2.4",
	"time": "2026-11-14 14:22 UTC",
	"location": "N18W42 (Active Region 3889)",
	"is_live": false
}

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

func _ready() -> void:
	fetch_nasa_solar_flare()

var api_key: String = Secrets.NASA_API_KEY.strip_edges()

func fetch_nasa_solar_flare() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_nasa_request_completed)
	
	# Son 30 günün gerçek Güneş patlamalarını çek (kesin veri gelmesi için)
	var unix_now = Time.get_unix_time_from_system()
	var end_date = Time.get_date_string_from_unix_time(unix_now)
	var start_date = Time.get_date_string_from_unix_time(unix_now - 30 * 86400)
	
	var url = "https://api.nasa.gov/DONKI/FLR?startDate=%s&endDate=%s&api_key=%s" % [start_date, end_date, api_key]
	print("[NASA API] URL: ", url.replace(api_key, "***"))
	http.request(url)

func _on_nasa_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var raw_text = body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[NASA API] Yanıt alınamadı (Kod: %d) -> Detay: %s" % [response_code, raw_text])
		return
		
	var json = JSON.parse_string(raw_text)
	if typeof(json) == TYPE_ARRAY and json.size() > 0:
		var latest = json[json.size() - 1]
		
		flare_data["class_type"] = str(latest.get("classType", "M1.8"))
		var raw_time = str(latest.get("peakTime", latest.get("beginTime", "")))
		flare_data["time"] = raw_time.replace("T", " ").replace("Z", " UTC")
		
		var loc = str(latest.get("sourceLocation", ""))
		var region = str(latest.get("activeRegionNum", ""))
		if loc != "":
			flare_data["location"] = "%s (AR %s)" % [loc, region] if region != "" else loc
		else:
			flare_data["location"] = "Solar Disk (Active Region %s)" % region
			
		flare_data["is_live"] = true
		emit_signal("nasa_flare_loaded")
		print("[NASA LIVE DONKI] Güneş Patlaması Yüklendi: ", flare_data)
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
		current_phase = "FLIGHT_RETURN"
		emit_signal("stats_updated")
		var main_scene = get_tree().current_scene
		if main_scene.has_method("load_space_flight"):
			main_scene.load_space_flight("RETURN")
