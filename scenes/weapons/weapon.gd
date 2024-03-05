extends Node3D

@onready var player_ref = get_tree().get_first_node_in_group("Player")
@onready var projectiles_ref = get_tree().get_first_node_in_group("Projectiles")
@export var current_weapon = false
@export var camera_shake_noise : FastNoiseLite

var offset : Vector3
var camera_shake_amp = 0.0
var camera_shake_time_left = 0.0

var projectile
var muzzle
var target_loc
var weapon_stats = []
var initialized = false
var weapon_name
var charge_time = 0

enum States{READY, PREPARING, RELOADING, CHARGING, INACTIVE};
var weapon_state= States.INACTIVE

func _ready():
	muzzle = %muzzle
	target_loc = %Target

func _process(delta):
	if camera_shake_time_left > 0:
		camera_shake_time_left -= delta
		camera_shake()
	if current_weapon:
		weapon_load()
	else:
		weapon_inactive()

func weapon_load():
	if weapon_state == States.INACTIVE:
		weapon_state= States.READY

func weapon_inactive():
	weapon_state= States.INACTIVE

func initialize_weapon(weapon):
	#weapon stats for mutability
	camera_shake_noise.seed = randi()
	weapon_name = weapon
	for attr in range(len(Data.all_data[Data.wcls][weapon].keys())):
		weapon_stats.append(Data.get_attr(Data.wcls,weapon,attr))
	initialized = true

func muzzle_flash():
	pass

func camera_shake():
	offset.y = camera_shake_noise.get_noise_3d(camera_shake_noise.seed*2,camera_shake_time_left,randf()) 
	offset.z = camera_shake_noise.get_noise_3d(camera_shake_noise.seed*3,camera_shake_time_left,randf())
	player_ref.camera_first_person.rotation.y = clampf(offset.y,0,camera_shake_amp)
	player_ref.camera_first_person.rotation.z = clampf(offset.z,0,camera_shake_amp)
	
func add_recoil(time,angle):
	player_ref.weapons[player_ref.active_weapon_index].rotate_z(angle)
	player_ref.camera_first_person.rotate_x(angle * weapon_stats[Data.wattr.MAX_RECOIL])
	player_ref.weapon_socket.rotation.z = player_ref.camera_first_person.rotation.x
	camera_shake_amp = weapon_stats[Data.wattr.RECOIL_AMOUNT]+1
	camera_shake_time_left = time
	camera_shake()
	await get_tree().create_timer(time,true).timeout
	player_ref.weapons[player_ref.active_weapon_index].rotate_z(-angle)
		
func fire():
	if is_instance_valid(projectiles_ref) and is_instance_valid(muzzle):
		if weapon_state == States.READY and initialized:
			shooting_pattern()
	else:
		printerr("references not set")

func shooting_pattern():
	pass

func fire_once():
	var this_projectile = projectile.instantiate()
	if player_ref.movement_ability:
		weapon_stats[Data.wattr.PROJECTILE_SPEED] = Data.get_attr(Data.wcls,weapon_name,Data.wattr.PROJECTILE_SPEED)
	this_projectile.weapon_stats = weapon_stats
	this_projectile.target = target_loc
	projectiles_ref.add_child(this_projectile)
	this_projectile.global_position = muzzle.global_position
	this_projectile.global_rotation = muzzle.global_rotation
	
func prepare_next_shot():
	add_recoil(weapon_stats[Data.wattr.RECOIL_TIME],weapon_stats[Data.wattr.RECOIL_AMOUNT])
	weapon_state = States.PREPARING
	await get_tree().create_timer(weapon_stats[Data.wattr.FIRE_RATE],false).timeout
	weapon_state = States.READY
	
