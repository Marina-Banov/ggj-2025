extends CanvasLayer

@onready var player = get_node("/root/Game/Player")


func _on_button_damage_pressed() -> void:
	player.damage += 1
	_resume()


func _on_button_speed_pressed() -> void:
	player.speed += 30
	_resume()


func _on_button_attack_speed_pressed() -> void:
	player.attack_speed -= 0.01
	_resume()


func _on_button_health_pressed() -> void:
	player.health = min(100, player.health + 10)
	_resume()


func _resume():
	Engine.time_scale = 1
	visible = false
	player.xp = 0
