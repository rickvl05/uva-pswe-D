extends Area2D


func _on_body_entered(body):
	assert($AnimatedSprite2D, "This function shouldn't be called if the" +
		"checkpoint has already been reached")
	if body.is_in_group("Player"):
		if body.name != str(multiplayer.get_unique_id()):
			return
		var checkpoint = Vector2(global_position.x, global_position.y - 25)
		body.set_checkpoint(checkpoint)
		if $AnimatedSprite2D.animation == "default":
			$AnimatedSprite2D.play("pop")
			GlobalAudioPlayer.initialize_SFX("balloon_pop", global_position,
			true)


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "pop":
		hide()
		$CollisionShape2D.disabled = true
		$AnimatedSprite2D.queue_free()
