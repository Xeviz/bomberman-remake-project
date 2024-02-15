extends TileMap

var time_to_vanish = 0.5

func check_if_vanish():
	if time_to_vanish<=0:
		get_tree().root.get_node("GameRoom").remove_child(self)
		queue_free()


func _process(delta):
	time_to_vanish -= delta
	check_if_vanish()
