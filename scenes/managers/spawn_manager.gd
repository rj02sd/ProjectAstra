extends Node3D

@onready var player_ref = get_tree().get_first_node_in_group("Player")
@onready var game_manager_ref = get_tree().get_first_node_in_group("GameManager")
@onready var segment_manager_ref = get_tree().get_first_node_in_group("SegmentManager")
var spawners = []

func _ready():
	gather_spawners()
	
func gather_spawners():
	"""
	legacy
	for spawner in get_tree().get_nodes_in_group("Spawner"):
		if spawner not in spawners:
			spawners.append(spawner)
	"""

func activate_spawners():
	"""
	legacy
	for spawner in spawners:
		if spawner.active and not spawner.spawned:
			spawner.spawn_enemies()
			spawner.spawned = true
			spawner.active = false
	"""
		
func disable_spawners():
	pass

func _process(_delta):
	gather_spawners()
	activate_spawners()
