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

const DAMAGE_RATE = 50.0
const MAX_SHIELD_HEALTH = 20.0

var xp = 0
var max_xp_per_level = 5
var level = 1

var speed = 450.0
var health = 100.0
var shield_health = MAX_SHIELD_HEALTH
@onready var attack_speed = shooting_timer.wait_time
var damage = 1

var target_position = Vector2()
var has_bubbles = ["normal"]
var has_shield = false
var has_shield_active = false


func _on_coin_collected():
	xp += 1


func _on_item_collected(type):
	if type != "carbon":
		has_bubbles.append(type)
	else:
		has_shield = true
		has_shield_active = true


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
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

	var overlapping_mobs = %Hurtbox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		if has_shield and has_shield_active:
			shield_health -= DAMAGE_RATE * overlapping_mobs.size() * delta
			if shield_health <= 0.0:
				has_shield_active = false
				shield_timer.start()
		else:
			health -= DAMAGE_RATE * overlapping_mobs.size() * delta
			if health <= 0.0:
				health_depleted.emit()

	var enemies_in_range = shooting_range.get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range[0]
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


func shoot(bubble_type):
	const BUBBLE = preload("res://bullet.tscn")
	var new_bubble = BUBBLE.instantiate()
	new_bubble.type = bubble_type
	new_bubble.global_position = %ShootingPoint.global_position
	new_bubble.look_at(target_position)
	%ShootingPoint.add_child(new_bubble)


func _on_shooting_timer_timeout() -> void:
	shoot(has_bubbles[randi() % has_bubbles.size()])


func _on_shield_timer_timeout() -> void:
	has_shield_active = true
	shield_health = MAX_SHIELD_HEALTH
