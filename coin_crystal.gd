extends Area2D
signal coin_collected

@onready var game = get_node("/root/Game")

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	coin_collected.emit()
