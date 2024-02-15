extends CharacterBody2D

var time_to_explode = 1
var bomb_range = 1
var player_name = "1"




func _ready():
	pass # Replace with function body.

func check_if_explode():
	if time_to_explode<=0:
		get_tree().root.get_node("GameRoom").remove_child(self)
		queue_free()


func _process(delta):
	time_to_explode -= delta
	check_if_explode()
	


func _on_tree_exiting():
	
	get_tree().root.get_node("GameRoom").get_node("1").refill_bomb()
	get_tree().root.get_node("GameRoom").get_node("1").generate_explosion(self, bomb_range)
	
