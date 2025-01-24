extends CharacterBody2D

signal health_depleted

const SPEED = 450.0
@onready var happy_boo: Node2D = $HappyBoo
@onready var health_bar: ProgressBar = $HealthBar

var health = 100.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
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
	
