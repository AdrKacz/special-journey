extends Node


var SERVER_PORT : int = 8081
var MAX_PLAYERS : int = 4
var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()

func _ready():
	var err = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	if (err):
		print("[Create Server Error]\n" + err)
	else:
		print("[Create Server]\nServing at port %d" % SERVER_PORT)
	get_tree().network_peer = peer
	
func _exit_tree():
	print("[Create Server]\nClose connection")
	get_tree().network_peer = null
	
