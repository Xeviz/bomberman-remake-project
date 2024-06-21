extends Control

signal found_server
signal server_removed
signal join_game(ip)
var broadcast_timer : Timer

var room_info = {"name":"name", "player_count": 0}
var broadcaster : PacketPeerUDP
var listner : PacketPeerUDP
@export var listen_port : int = 8911
@export var broadcast_port : int = 8912
@export var broadcast_address : String = '169.254.255.255' # 192.168.71.255
@export var server_info : PackedScene


func _ready():
	broadcast_timer = $BroadcastTimer
	set_up()
	
func set_up():
	listner = PacketPeerUDP.new()
	var ok = listner.bind(listen_port)
	
	if ok == OK:
		print("Bound to listen Port "  + str(listen_port) +  " Successful!")
		$Label.text="Bound To Listen Port: true"
	else:
		print("Failed to bind to listen port!")
		$Label.text="Bound To Listen Port: false"
		

func set_up_broadcast(name):
	room_info.name = name
	room_info.player_count = GameManager.players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcast_address, listen_port)
	
	var ok = broadcaster.bind(broadcast_port)
	
	if ok == OK:
		print("Bound to Broadcast Port "  + str(broadcast_address) +  " Successful!")
	else:
		print("Failed to bind to broadcast port!")
		
	$BroadcastTimer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if listner.get_available_packet_count() > 0:
		var server_ip = listner.get_packet_ip()
		var server_port = listner.get_packet_port()
		var bytes = listner.get_packet()
		var data = bytes.get_string_from_ascii()
		var room_info = JSON.parse_string(data)
		
		print("server Ip: " + server_ip +" serverPort: "+ str(server_port) + " room info: " + str(room_info))
		
		for i in $Panel/VBoxContainer.get_children():
			if i.name == room_info.name:
				i.get_node("Ip").text = server_ip
				i.get_node("PlayerCount").text = str(room_info.player_count)
				return

		var current_info = server_info.instantiate()
		current_info.name = room_info.name
		current_info.get_node("Name").text = room_info.name
		current_info.get_node("Ip").text = server_ip
		current_info.get_node("PlayerCount").text = str(room_info.player_count)
		$Panel/VBoxContainer.add_child(current_info)
		current_info.join_game.connect(join_by_ip)
		


func _on_broadcast_timer_timeout():
	print("Broadcasting Game!")
	room_info.player_count = GameManager.players.size()
	var data = JSON.stringify(room_info)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func cleanUp():
	listner.close()
	
	$BroadcastTimer.stop()
	if broadcaster != null:
		broadcaster.close()

func _exit_tree():
	cleanUp()

func join_by_ip(ip):
	join_game.emit(ip)
