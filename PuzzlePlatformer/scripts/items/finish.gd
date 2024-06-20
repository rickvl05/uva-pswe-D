extends Area2D


@export var next_level_number: int
@export var current_level_number: int

const level_music = preload("res://assets/music/peacefulsong.mp3")


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		GlobalAudioPlayer.play_music(level_music)
		MultiplayerManager.set_accept_new_connections(false)
		get_tree().root.get_node("Game").change_level(next_level_number)
