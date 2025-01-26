extends Area2D

signal pickup_collected(type: String)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var type: String = "normal"

func _ready() -> void:
	animated_sprite.animation = type
	if type == "normal":
		animated_sprite.scale.x = 1
		animated_sprite.scale.y = 1
		animated_sprite.play()
		animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	await get_tree().create_timer(1.).timeout
	animated_sprite.play()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
	pickup_collected.emit(type)
