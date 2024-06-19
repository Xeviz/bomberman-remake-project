extends Control

@export var address = "10.182.22.210" #192.168.68.102
@export var port = 8910
var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		host_game()
	
	$ServerBrowser.join_game.connect(join_by_ip)
		
func _process(delta):
	pass

func peer_connected(id):
	print("Player connected " + str(id))
		
func peer_disconnected(id):
	print("Player disconnected " + str(id))
	GameManager.players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

func connected_to_server():
	print ("Connected to Server!")
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

func connection_failed():
	print ("Connection failed!")

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name":name,
			"id":id,
			"score": 0,
			"map_position": Vector2i(0,0)
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)
	
@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://GameRoom.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("couldn't host - " + error)
		return

	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for another player")
	


func _on_host_button_down():
	host_game()
	send_player_information($LineEdit.text, multiplayer.get_unique_id())
	$ServerBrowser.set_up_broadcast($LineEdit.text + "'s server")
	
	
func join_by_ip(ip):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_down():
	start_game.rpc()
	pass # Replace with function body.
	

