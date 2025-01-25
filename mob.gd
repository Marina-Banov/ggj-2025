extends CharacterBody2D

signal mob_died

var speed = 200.0
var health = 5
var is_poisoned = false
var damage_over_time_rate = 0.5

# "hardcoded" method of getting player
# dok se vrti igra, dobije se "remote" tab lijevo u inspectoru
# tamo se provjeri kao finalna hijerarhija nodeova za dohvacanje
@onready var player = get_node("/root/Game/Player")
@onready var slime: Node2D = $Slime
@onready var game = get_node("/root/Game")
@onready var chlorine_timer: Timer = $ChlorineTimer


func _ready() -> void:
	slime.play_walk()


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()


func take_damage(damage=player.damage):
	health -= damage
	slime.play_hurt()
	if health <= 0:
		_spawn_smoke_and_coin()
		die()


func decrease_speed():
	speed = max(1.0, speed-50.0)


func get_poisoned():
	if not is_poisoned:
		is_poisoned = true
		chlorine_timer.start()


func _spawn_smoke_and_coin():
	const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	
	const CRYSTAL = preload("res://coin_crystal.tscn")
	var coin = CRYSTAL.instantiate()
	#get_parent().add_child(coin)
	# BITNO I ODVRATNO - something something collision physics object brrrr aaaaa
	get_parent().call_deferred("add_child", coin)
	coin.global_position = global_position
	coin.coin_collected.connect(player._on_coin_collected)


func die():
	game.increment_score()
	mob_died.emit()
	queue_free()


func _on_chlorine_timer_timeout() -> void:
	if is_poisoned:
		take_damage(damage_over_time_rate)
