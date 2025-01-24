extends CharacterBody2D
signal mob_died
const SPEED = 300
var health = 3

# "hardcoded" method of getting player
# dok se vrti igra, dobije se "remote" tab lijevo u inspectoru
# tamo se provjeri kao finalna hijerarhija nodeova za dohvacanje
@onready var player = get_node("/root/Game/Player")
@onready var slime: Node2D = $Slime
@onready var game = get_node("/root/Game")


func _ready() -> void:
	slime.play_walk()
	

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	move_and_slide()


func take_damage():
	health -= 1
	slime.play_hurt()
	if health <= 0:
		die()
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		
		const CRYSTAL = preload("res://coin_crystal.tscn")
		var coin = CRYSTAL.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position

func die():
	game.increment_score()
	mob_died.emit()
	queue_free()
