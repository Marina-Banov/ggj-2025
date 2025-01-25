extends CharacterBody2D

signal boss_died

const SPEED = 0
var health = 20
var is_poisoned = false
var damage_over_time_rate = 0.5

@onready var player = get_node("/root/Game/Player")
@onready var slime: Node2D = $Slime
@onready var game = get_node("/root/Game")
@onready var health_bar: ProgressBar = $HealthBar
@onready var chlorine_timer: Timer = $ChlorineTimer


func _ready() -> void:
	health_bar.value = health


func get_poisoned():
	if not is_poisoned:
		is_poisoned = true
		chlorine_timer.start()


func decrease_speed():
	pass


func add_pushback(force: Vector2) -> void:
	pass


func take_damage(damage=player.damage):
	health -= damage
	slime.play_hurt()
	health_bar.value = health
	if health <= 0:
		_spawn_smoke_and_coin()
		die()


func _spawn_smoke_and_coin():
	const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	
	const ITEM = preload("res://item.tscn")
	var item = ITEM.instantiate()
	item.type = get_meta("type")
	#get_parent().add_child(item)
	# BITNO I ODVRATNO - something something collision physics object brrrr aaaaa
	get_parent().call_deferred("add_child", item)
	item.global_position = global_position
	item.item_collected.connect(player._on_item_collected)


func die():
	game.increment_score()
	boss_died.emit()
	queue_free()


func _on_chlorine_timer_timeout() -> void:
	if is_poisoned:
		take_damage(damage_over_time_rate)
