extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_node("/root/Game/Player")

const RANGE: float = 1000.

var travelled_distance: float = 0.
var type: String = "normal"


func _ready() -> void:
	animated_sprite.play(type)


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	position += direction * player.bubble_speed * delta
	travelled_distance += player.bubble_speed * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("take_damage"):
		return

	body.take_damage()
	match type:
		"chlorine":
			body.get_poisoned()
		"oxygen":
			var pushback_dir: Vector2 = (body.global_position - global_position).normalized() * 1000.
			body.add_pushback(pushback_dir)
		"hydrogen":
			body.decrease_speed()

	# Play sound before freeing the current node
	var death_sound = preload("res://assets/music/bubblepop.mp3")  # Path to your sound file
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = death_sound
	add_child(sfx_player)  # Add it to the root so it's not freed with the current node
	sfx_player.play()
	await get_tree().create_timer(0.05).timeout  # Replace 2.5 with the sound duration	
	
	queue_free()
	
