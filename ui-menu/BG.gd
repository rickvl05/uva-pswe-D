extends ParallaxBackground

var speed = 45

func _process(delta):
	scroll_offset.x -= speed * delta
