extends Node2D


func _ready() -> void:
	%Smoke.material.set_shader_parameter("texture_offset", Vector2(randfn(0., 1.), randfn(0., 1.)))
	%AnimationPlayer.play("explosion")
	await %AnimationPlayer.animation_finished
	queue_free()
