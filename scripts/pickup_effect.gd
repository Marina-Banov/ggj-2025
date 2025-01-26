extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 0
	var type = get_meta("type")
	var new_texture
	match type:
		"chlorine":
			new_texture = load("res://assets/pickup_chlorine/cl2(1).png")
		"oxygen":
			new_texture = load("res://assets/pickup_oxygen/o2(1).png")
		"hydrogen":
			new_texture = load("res://assets/pickup_hydrogen/h2(1).png")
		"carbon":
			new_texture = load("res://assets/pickup_carbon/c02(1).png")
	$ColorRect/Sprite2D.texture = new_texture
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Engine.time_scale = 1
		queue_free()
