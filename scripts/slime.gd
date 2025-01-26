extends Node2D


func play_walk() -> void:
	%AnimationPlayer.play("walk")


func play_hurt() -> void:
	%AnimationPlayer.play("hurt")
	%AnimationPlayer.queue("walk")
