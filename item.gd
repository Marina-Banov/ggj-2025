extends Area2D

signal item_collected(type)

var type = "oxygen"

func _ready():
	$AnimatedSprite2D.animation = type

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	item_collected.emit(type) # otkrit kako passat type
