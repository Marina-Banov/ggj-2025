extends CanvasLayer

@onready var player: CharacterBody2D = get_node("/root/Game/Player")


func _on_button_damage_pressed() -> void:
	player.increase_damage()
	_resume()


func _on_button_speed_pressed() -> void:
	player.increase_speed()
	_resume()


func _on_button_attack_speed_pressed() -> void:
	player.increase_attack_speed()
	_resume()


func _on_button_health_pressed() -> void:
	player.heal()
	_resume()


func _resume() -> void:
	Engine.time_scale = 1
	visible = false
