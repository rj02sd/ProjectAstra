extends Area3D

@onready var player_ref = get_tree().get_first_node_in_group("Player")

var velocity = Vector3.ZERO
var weapon_stats = []
var weapon
var target

signal hit(damage,headshot)

func _ready():
	aim_shot()
	apply_jitter()

func apply_jitter():
	self.transform = self.transform.rotated_local(Vector3.UP, randf_range(-weapon_stats[Data.wattr.JITTER], weapon_stats[Data.wattr.JITTER]))
	self.transform = self.transform.rotated_local(Vector3.RIGHT, randf_range(-weapon_stats[Data.wattr.JITTER], weapon_stats[Data.wattr.JITTER]))
	
func aim_shot():
	var max_inaccuracy = weapon_stats[Data.wattr.MAX_SPREAD] * (100-weapon_stats[Data.wattr.ACCURACY])/100.0
	var offsetx = randf_range(-max_inaccuracy,max_inaccuracy)
	var offsety = randf_range(-max_inaccuracy,max_inaccuracy)
	var offsetz = randf_range(-max_inaccuracy,max_inaccuracy)
	
	var new_target = Vector3(target.global_position.x+offsetx,
							target.global_position.y+offsety,
							target.global_position.z+offsetz)
							
	look_at(new_target)
	transform = player_ref.transform
	velocity = global_position.direction_to(new_target) * weapon_stats[Data.wattr.PROJECTILE_SPEED]

func _process(_delta):
	pass

func damage_enemy(enemy,headshot):
	if enemy.has_method("on_hit"):
		var damage = weapon_stats[Data.wattr.DAMAGE]
		var crit = randf_range(1,100)
		if crit < weapon_stats[Data.wattr.CRITICAL_CHANCE]:
			damage *= weapon_stats[Data.wattr.CRITICAL_DAMAGE]
		if not hit.is_connected(enemy.on_hit):
			hit.connect(enemy.on_hit)
		if headshot:
			hit.emit(damage*weapon_stats[Data.wattr.HEADSHOT_MULTIPLIER])
		else:
			hit.emit(damage)
		sdestruct()
	
func sdestruct():
	call_deferred("queue_free")
	
func _physics_process(delta):
	global_position += velocity * delta

func regular_hit(body):
	if body.is_in_group("Enemy"):
		damage_enemy(body,false)
	if body != player_ref:
		sdestruct()

func headshot_hit(area):
	if area.is_in_group("HeadshotCol"):
		damage_enemy(area.owner,true)
