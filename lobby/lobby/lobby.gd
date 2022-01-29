extends Control

var is_valid_ip_address : bool = false
var is_valid_port : bool = false

# Initialise useful accessors
onready var join_box : MarginContainer = $MarginContainer/VBoxContainer/JoinAndHostContainer/Join
onready var join_host_separator : VSeparator = $MarginContainer/VBoxContainer/JoinAndHostContainer/VSeparator
onready var host_box : MarginContainer = $MarginContainer/VBoxContainer/JoinAndHostContainer/Host

onready var form_ip_address : LineEdit = $MarginContainer/VBoxContainer/JoinAndHostContainer/Join/VBoxContainer/Form/IPAddress/LineEdit
onready var form_port : LineEdit = $MarginContainer/VBoxContainer/JoinAndHostContainer/Join/VBoxContainer/Form/Port/LineEdit

onready var join_label : Label = $MarginContainer/VBoxContainer/JoinAndHostContainer/Join/VBoxContainer/Label
onready var host_label : Label = $MarginContainer/VBoxContainer/JoinAndHostContainer/Host/VBoxContainer/Label

onready var join_button : Button = $MarginContainer/VBoxContainer/JoinAndHostContainer/Join/VBoxContainer/Button
onready var host_button : Button = $MarginContainer/VBoxContainer/JoinAndHostContainer/Host/VBoxContainer/HostButton

onready var chat : RichTextLabel = $MarginContainer/VBoxContainer/Chat/ChatContainer/RichTextLabel
onready var chat_input : LineEdit = $MarginContainer/VBoxContainer/Chat/SendChatContainer/HBoxContainer/LineEdit


# Register to Networking signal
func _ready() -> void:
	NetworkManager.connect("lobby_created", self, "_on_Lobby_Created")
	NetworkManager.connect("lobby_joined", self, "_on_Lobby_Joined")
	NetworkManager.connect("lobby_leaved", self, "_on_Lobby_Leaved")
	NetworkManager.connect("network_message", self, "_on_Network_Message")

func _on_HostButton_pressed() -> void:
	if host_button.text == "Host lobby":
		# Hide Join Box
		join_host_separator.hide()
		join_box.hide()
		host_button.disabled = true
		# Create lobby
		host_label.text = "Creating lobby..."
		NetworkManager.hostNewLobby()
	elif host_button.text == "Leave lobby":
		host_label.text = "Leaving lobby..."
		NetworkManager.leaveCurrentLobby()

func _on_IPAddress_text_changed(new_text : String) -> void:
	is_valid_ip_address = new_text.is_valid_ip_address()
	validate_join_input()

func _on_Port_text_changed(new_text : String) -> void:
	is_valid_port = new_text.is_valid_integer()
	validate_join_input()
	
func validate_join_input() -> void:
	if is_valid_ip_address and is_valid_port:
		join_button.disabled = false
	else:
		join_button.disabled = true

func _on_JoinButton_pressed() -> void:
	if join_button.text == "Join lobby":
		# Hide Host Box
		join_host_separator.hide()
		host_box.hide()
		join_button.disabled = true
		form_ip_address.editable = false
		form_port.editable = false
		# Join lobby
		join_label.text = "Joining lobby..."
		NetworkManager.joinLobby(form_ip_address.text, int(form_port.text))
	elif join_button.text == "Leave lobby":
		join_label.text = "Leaving lobby..."
		NetworkManager.leaveCurrentLobby()

func _on_SendChatButton_pressed() -> void:
	rpc("add_chat_message", chat_input.text)
	chat_input.text = ""
	
func _on_Lobby_Created(ip_address: String, port: int) -> void:
	host_label.text = "Create lobby at " + ip_address + " on " + String(port)
	host_button.text = "Leave lobby"
	host_button.disabled = false
	
func _on_Lobby_Joined() -> void:
	join_label.text = "Joined lobby"
	join_button.text = "Leave lobby"
	join_button.disabled = false
	
func _on_Lobby_Leaved() -> void:
	form_ip_address.editable = true
	form_port.editable = true
	join_host_separator.show()
	host_box.show()
	join_box.show()
	join_button.text = "Join lobby"
	host_button.text = "Host lobby"
	join_label.text = "Status: IDLE"
	host_label.text = "Status: IDLE"
	
func _on_Network_Message(message : String) -> void:
	var message_splitted : PoolStringArray = message.split("::")
	if message_splitted[0] == "connected":
		add_system_chat_message("%010d enters the lobby!" % int(message_splitted[1]))
	elif message_splitted[0] == "disconnected":
		add_system_chat_message("%010d leaves the lobby!" % int(message_splitted[1]))

func add_system_chat_message(message : String) -> void:
	chat.text += "\n%s" % message

remotesync func add_chat_message(message : String) -> void:
	var local_peer_id : int= get_tree().get_rpc_sender_id()
	chat.text += "\n[%010d] > %s" % [local_peer_id, message]
