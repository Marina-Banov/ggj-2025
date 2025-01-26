extends CharacterBody2D

signal enemy_died

@onready var game: Node2D = get_node("/root/Game")
@onready var player: CharacterBody2D = get_node("/root/Game/Player")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var chlorine_timer: Timer = $ChlorineTimer

var type: String = "normal"
var is_grunt: bool = true
var speed: float = 200.
var health: float = 3.
var is_poisoned: bool = false
var damage_over_time_rate: float = 0.5
var pushback_force: Vector2 = Vector2.ZERO

const SCALE_FACTOR = {
	"boss_carbon": 3.266 * 1.5,
	"boss_chlorine": 1. * 1.5,
	"boss_hydrogen": 1. * 1.5,
	"boss_oxygen": 1. * 1.5,
	"grunt_carbon": 0.103 * 1.1,
	"grunt_chlorine": 1.015 * 1.1,
	"grunt_hydrogen": 0.117 * 1.1,
	"grunt_oxygen": 0.094 * 1.1,
}

const FPS = {
	"boss_carbon": 59 * 0.1,
	"boss_chlorine": 2 * 1.0,
	"boss_hydrogen": 22 * 0.2,
	"boss_oxygen": 20 * 0.3,
	"grunt_carbon": 18 * 0.3,
	"grunt_chlorine": 10 * 0.5,
	"grunt_hydrogen": 29 * 0.18,
	"grunt_oxygen": 12 * 0.4,
}


func _ready() -> void:
	type = get_meta("type")
	is_grunt = get_meta("is_grunt")
	if not is_grunt:
		speed = 0.
		health = 20.
		health_bar.max_value = health
		health_bar.value = health
		health_bar.visible = true
	var animation_type: String = "%s_%s" % (["grunt" if is_grunt else "boss", type])
	animated_sprite.play(animation_type)
	animated_sprite.scale.x = SCALE_FACTOR[animation_type]
	animated_sprite.scale.y = SCALE_FACTOR[animation_type]
	animated_sprite.speed_scale = FPS[animation_type]


func _physics_process(_delta: float) -> void:
	if not is_grunt:
		return
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * speed + pushback_force
	move_and_slide()
	pushback_force = lerp(pushback_force, Vector2.ZERO, 0.1)


func take_damage(damage=player.damage) -> void:
	health -= damage
	# animated_sprite.play("hurt")
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
	const EXPLOSION: Resource = preload("res://scenes/explosion.tscn")
	var explosion: Node2D = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position


func drop_pickup() -> void:
	const PICKUP: Resource = preload("res://scenes/pickup.tscn")
	var pickup: Area2D = PICKUP.instantiate()
	pickup.type = "normal" if is_grunt else type
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
