extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300
const RANGE = 1000

var travelled_distance = 0
var type = "normal"


func _ready() -> void:
	animated_sprite.play(type)


func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
		match type:
			"chlorine":
				body.get_poisoned()
			"oxygen": # Push back
				pass
			"hydrogen":
				body.decrease_speed()
