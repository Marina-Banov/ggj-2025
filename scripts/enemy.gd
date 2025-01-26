extends CharacterBody2D

signal enemy_died

@onready var game: Node2D = get_node("/root/Game")
@onready var player: CharacterBody2D = get_node("/root/Game/Player")

@onready var slime: Node2D = $Slime
@onready var health_bar: ProgressBar = $HealthBar
@onready var chlorine_timer: Timer = $ChlorineTimer

var type: String = "normal"
var is_grunt: bool = true
var speed: float = 200.
var health: float = 3.
var is_poisoned: bool = false
var damage_over_time_rate: float = 0.5
var pushback_force: Vector2 = Vector2.ZERO


func _ready() -> void:
	type = get_meta("type")
	is_grunt = get_meta("is_grunt")
	if not is_grunt:
		speed = 0.
		health = 20.
		health_bar.max_value = health
		health_bar.value = health
		health_bar.visible = true
		scale.x = 3.
		scale.y = 3.
	slime.play_walk()


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * speed + pushback_force
	move_and_slide()
	pushback_force = lerp(pushback_force, Vector2.ZERO, 0.1)


func take_damage(damage=player.damage) -> void:
	health -= damage
	slime.play_hurt()
	health_bar.value = health
	if health <= 0:
		explode()
		drop_pickup()
		die()


func add_pushback(force: Vector2) -> void:
	if is_grunt:
		pushback_force = force


func decrease_speed() -> void:
	if is_grunt:
		speed = max(1., speed-50.)


func get_poisoned() -> void:
	if not is_poisoned:
		is_poisoned = true
		chlorine_timer.start()


func explode() -> void:
	const EXPLOSION: Resource = preload("res://scenes/smoke_explosion.tscn")
	var explosion: Node2D = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position


func drop_pickup() -> void:
	const PICKUP: Resource = preload("res://scenes/pickup.tscn")
	var pickup: Area2D = PICKUP.instantiate()
	pickup.type = type
	get_parent().call_deferred("add_child", pickup)
	pickup.global_position = global_position
	pickup.pickup_collected.connect(player._on_pickup_collected)


func die() -> void:
	game.increment_score()
	enemy_died.emit()
	queue_free()


func _on_chlorine_timer_timeout() -> void:
	if is_poisoned:
		take_damage(damage_over_time_rate)
