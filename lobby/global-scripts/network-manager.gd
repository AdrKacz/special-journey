extends Node

# Useful Networking Signal to register to
signal lobby_created(ip_address, port)
signal lobby_joined
signal lobby_leaved
signal network_message(message)

var SERVER_PORT : int = 8080
var MAX_PLAYERS : int = 4
var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()

var peers : PoolIntArray = PoolIntArray()

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_Network_Peer_Connected")
	get_tree().connect("network_peer_disconnected", self, "_on_Network_Peer_Disconnected")
	if OS.has_feature("Server"):
		SERVER_PORT = 8081
		hostNewLobby()
		print("Lobby created at 127.0.0.1:8081")
		
func _exit_tree():
	if OS.has_feature("Server"):
		leaveCurrentLobby()
		print("Closed connection")

func hostNewLobby() -> void:
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	
	# TODO: Get IP Address of host
	emit_signal("lobby_created", "127.0.0.1", SERVER_PORT)

func leaveCurrentLobby() -> void:
	get_tree().network_peer = null # don't seem to work when you're not the server
	emit_signal("lobby_leaved")
	
func joinLobby(ip_address: String, port: int) -> void:
	peer.create_client(ip_address, port)
	get_tree().network_peer = peer
	
func _on_Network_Peer_Connected(id : int) -> void:
	print("[on_Network_Peer_Connected] ID: " + String(id))
	if (id == 1):
		emit_signal("lobby_joined")
	else:
		peers.append(id)
	emit_signal("network_message", "connected::" + String(id))
	
func _on_Network_Peer_Disconnected(id : int) -> void:
	# Todo: What if server disconnect
	print("[on_Network_Peer_Disconnected] ID: " + String(id))
	emit_signal("network_message", "disconnected::" + String(id))
