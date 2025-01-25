extends CharacterBody2D

signal health_depleted
signal should_level_up

@onready var happy_boo: Node2D = $HappyBoo
@onready var health_bar: ProgressBar = get_node("/root/Game/HUD/HealthBar")
@onready var xp_bar: ProgressBar = get_node("/root/Game/HUD/XPBar")
@onready var gun: Area2D = $Gun

var xp = 0
var level = 1

var speed = 450.0
var health = 100.0
@onready var attack_speed = gun.timer.wait_time
var damage = 1

func _on_coin_collected():
	xp += 1

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	if velocity.length() > 0:
		happy_boo.play_walk_animation()
	else:
		happy_boo.play_idle_animation()
	
	const DAMAGE_RATE = 50.0
	var overlapping_mobs = %Hurtbox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		print(health)
		if health <= 0.0:
			health_depleted.emit() # unused but usefull
			print("dead")
	health_bar.value = health
	xp_bar.value = xp
	if xp == xp_bar.max_value:
		should_level_up.emit()
	gun.timer.wait_time = attack_speed
