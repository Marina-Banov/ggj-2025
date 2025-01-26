extends CharacterBody2D

signal health_depleted
signal should_level_up

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_range: Area2D = $ShootingRange
@onready var shield: Sprite2D = $Shield
@onready var shooting_timer: Timer = $ShootingTimer
@onready var shield_timer: Timer = $ShieldTimer

@onready var health_bar: ProgressBar = get_node("/root/Game/HUD/HealthBar")
@onready var xp_bar: ProgressBar = get_node("/root/Game/HUD/XPBar")

const DAMAGE_RATE: float = 50.
const MAX_SHIELD_HEALTH: float = 20.

var xp: int = 0
var max_xp_per_level: int = 5
var level: int = 1

var speed: float = 450.
var health: float = 100.
var shield_health: float = MAX_SHIELD_HEALTH
var attack_speed: float = 0.35
var damage: float = 1.

var target_position: Vector2 = Vector2()
var has_bubbles: Array[String] = ["normal"]
var has_shield: bool = false
var has_shield_active: bool = false


func _ready() -> void:
	shooting_timer.wait_time = attack_speed


func _physics_process(delta: float) -> void:
	if Engine.time_scale < 0.001:
		return

	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	# TODO manipulate opacity instead of toggling visibility
	shield.visible = has_shield and has_shield_active

	if velocity.length() > 0:
		animated_sprite.play("walk")
		if velocity.x < 0:
			animated_sprite.flip_h = true
			%ShootingPoint.position.x = -abs(%ShootingPoint.position.x)
		else:
			animated_sprite.flip_h = false
			%ShootingPoint.position.x = abs(%ShootingPoint.position.x)
	else:
		animated_sprite.play("idle")

	var overlapping_mobs: Array[Node2D] = %Hurtbox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		if has_shield and has_shield_active:
			shield_health -= DAMAGE_RATE * overlapping_mobs.size() * delta
			if shield_health <= 0.:
				has_shield_active = false
				shield_timer.start()
		else:
			health -= DAMAGE_RATE * overlapping_mobs.size() * delta
			if health <= 0.:
				health_depleted.emit()

	var enemies_in_range: Array[Node2D] = shooting_range.get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		# TODO aim at the closest enemy, not the first
		var target_enemy: Node2D = enemies_in_range[0]
		target_position = target_enemy.global_position

	health_bar.value = health
	xp_bar.value = xp
	xp_bar.max_value = max_xp_per_level
	if xp >= max_xp_per_level:
		should_level_up.emit()
		xp = 0
		level += 1
		max_xp_per_level = 5 * level
	shooting_timer.wait_time = attack_speed


func shoot(bubble_type: String) -> void:
	const BUBBLE: Resource = preload("res://scenes/bubble.tscn")
	var new_bubble: Area2D = BUBBLE.instantiate()
	new_bubble.type = bubble_type
	new_bubble.global_position = %ShootingPoint.global_position
	new_bubble.look_at(target_position)
	%ShootingPoint.add_child(new_bubble)


func increase_damage() -> void:
	damage += 1


func increase_speed() -> void:
	speed += 30.


func increase_attack_speed() -> void:
	attack_speed = max(0.1, attack_speed - 0.05)


func heal() -> void:
	health = min(100., health + 10.)


func _on_pickup_collected(type: String) -> void:
	if type == "normal":
		xp += 1
	elif type == "carbon":
		has_shield = true
		has_shield_active = true
	else:
		has_bubbles.append(type)


func _on_shooting_timer_timeout() -> void:
	shoot(has_bubbles[randi() % has_bubbles.size()])


func _on_shield_timer_timeout() -> void:
	has_shield_active = true
	shield_health = MAX_SHIELD_HEALTH
