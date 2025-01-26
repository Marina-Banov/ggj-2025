extends Node2D

@onready var path_follow_2d: PathFollow2D = $Player/Path2D/PathFollow2D
@onready var label: Label = $GameOver/ColorRect/Label
@onready var score_label: Label = $HUD/Score
@onready var gameover: CanvasLayer = $GameOver
@onready var levelup: CanvasLayer = $LevelUp

const ENEMY_TYPES: Array[String] = ["carbon", "chlorine", "hydrogen", "oxygen"]
var score: int = 0


func _ready() -> void:
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()


func pickup_effect(type):
	const pickup_effect_screen: Resource = preload("res://scenes/pickup_effect.tscn")
	var new_scene: CanvasLayer = pickup_effect_screen.instantiate()
	new_scene.set_meta("type", type)
	add_child(new_scene)


func spawn_mob() -> void:
	const ENEMY: Resource = preload("res://scenes/enemy.tscn")
	var new_mob: CharacterBody2D = ENEMY.instantiate()
	path_follow_2d.progress_ratio = randf()
	new_mob.global_position = path_follow_2d.global_position
	var type: String = ENEMY_TYPES[randi() % ENEMY_TYPES.size()]
	new_mob.set_meta("type", type)
	new_mob.set_meta("is_grunt", true)
	add_child(new_mob)


func increment_score(amount=1) -> void:
	score += amount
	score_label.text = str(score)


func _on_mob_spawn_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	gameover.visible = true
	label.text = str(score)
	Engine.time_scale = 0
	#get_tree().reload_current_scene()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && gameover.visible:
		Engine.time_scale = 1
		get_tree().reload_current_scene()


func _on_player_should_level_up() -> void:
	levelup.on_level_up()
	Engine.time_scale = 0
