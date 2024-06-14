extends LineEdit


func _enter_tree():
	$CharacterLimitLabel.text = "0/" + str(max_length)


func _on_text_changed(new_text):
	$CharacterLimitLabel.text = str(new_text.length()) + "/" + str(max_length)
