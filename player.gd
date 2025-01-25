extends CharacterBody2D

signal health_depleted
signal should_level_up

@onready var al: Node2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = get_node("/root/Game/HUD/HealthBar")
@onready var xp_bar: ProgressBar = get_node("/root/Game/HUD/XPBar")
@onready var timer: Timer = $Timer
@onready var shooting_range: Area2D = $ShootingRange

const DAMAGE_RATE = 50.0

var xp = 0
var max_xp_per_level = 5
var level = 1

var speed = 450.0
var health = 100.0
@onready var attack_speed = timer.wait_time
var damage = 1

var target_position = Vector2()

func _on_coin_collected():
	xp += 1

func _on_item_collected(type):
	match type:
		"chlorine": # DoT
			pass
		"oxygen": # Push back
			pass
		"carbon": # shield
			pass
		"hydrogen": # enemy speed
			pass


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	if velocity.length() > 0:
		al.play("walk")
		if velocity.x < 0:
			al.flip_h = true
			%ShootingPoint.position.x = -abs(%ShootingPoint.position.x)
		else:
			al.flip_h = false
			%ShootingPoint.position.x = abs(%ShootingPoint.position.x)
	else:
		al.play("idle")
	
	var overlapping_mobs = %Hurtbox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
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
	timer.wait_time = attack_speed


func shoot():
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.look_at(target_position)
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
