extends CharacterBody2D

var time_to_explode = 2
var bomb_range = 2
var player_name = "1"





func _ready():
	get_node("CollisionShape2D").disabled = true

func check_if_explode():
	if time_to_explode<=0:
		get_tree().root.get_node("GameRoom").remove_child(self)
		queue_free()
		
func detect_if_turn_on_collision():
	var player_pos = get_tree().root.get_node("GameRoom").get_node(player_name).get_player_position_on_map()
	if(player_pos.x != int(position.x/50) or player_pos.y != int(position.y/50)):
		get_node("CollisionShape2D").disabled = false


func _process(delta):
	
	time_to_explode -= delta
	detect_if_turn_on_collision()
	check_if_explode()
	


func _on_tree_exiting():
	
	get_tree().root.get_node("GameRoom").get_node(player_name).refill_bomb()
	get_tree().root.get_node("GameRoom").get_node(player_name).generate_explosion(self, bomb_range)
	
