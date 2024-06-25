extends Area2D


@export var next_level_number: int
@export var current_level_number: int


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		MultiplayerManager.leave_game()
		var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
		get_tree().root.add_child(main_menu)
		get_tree().root.get_node("Game").queue_free()
		self.queue_free()
