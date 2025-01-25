extends CharacterBody2D

signal boss_died

const SPEED = 0
var health = 10

@onready var player = get_node("/root/Game/Player")
@onready var slime: Node2D = $Slime
@onready var game = get_node("/root/Game")
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	health_bar.value = health


func take_damage():
	health -= player.damage
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
