extends CanvasLayer

@onready var player: CharacterBody2D = get_node("/root/Game/Player")

@onready var atk_speed: Sprite2D = $AtkSpeedBtn
@onready var dmg: Sprite2D = $DmgBtn
@onready var hp: Sprite2D = $HpBtn
@onready var speed: Sprite2D = $SpeedBtn
@onready var bubble_speed: Sprite2D = $BubbleSpeedBtn

var positions = [797, 1230]
var buttons = [atk_speed, dmg, speed, bubble_speed]

func on_level_up():
	visible = true
	var buttons2 = [atk_speed, dmg, speed, bubble_speed]
	
	for button in buttons2:
		button.visible = false
	# Randomly select 2 unique buttons
	var selected_buttons = []
	while selected_buttons.size() < 2:
		var random_index = randi() % buttons2.size()
		selected_buttons.append(buttons2[random_index])
		buttons2.pop_at(random_index)

	# Show the selected buttons
	var i = 0
	for button in selected_buttons:
		button.visible = true
		button.position.x = positions[i]
		i += 1

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

func _on_button_bubble_speed_pressed() -> void:
	player.increase_bubble_speed()
	_resume()

func _resume() -> void:
	Engine.time_scale = 1
	visible = false
