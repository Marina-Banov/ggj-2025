extends Node2D
@onready var path_follow_2d: PathFollow2D = $Player/Path2D/PathFollow2D
@onready var label: Label = $CanvasLayer2/ColorRect/Label
@onready var gameover: CanvasLayer = $CanvasLayer2

var score = 0

func _ready() -> void:
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()
	
func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	path_follow_2d.progress_ratio = randf()
	new_mob.global_position = path_follow_2d.global_position
	add_child(new_mob)

func increment_score(amount = 1) -> void:
	score += amount

func _on_mob_spawn_timer_timeout() -> void:
	spawn_mob()

func _on_player_health_depleted() -> void:
	gameover.visible = true
	label.text = str(score)
	Engine.time_scale = 0
	#get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Engine.time_scale = 1
		get_tree().reload_current_scene()
