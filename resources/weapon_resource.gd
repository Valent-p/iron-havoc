extends Resource
class_name WeaponResource

@export_group("Stats")
@export var weapon_name: String = "Vulcan Cannon"
@export var damage: float = 10.0
@export var fire_rate: float = 0.1 # Time between shots (0.1 = 10 shots/sec)
@export var projectile_speed: float = 50.0
@export var projectile_lifetime: float = 3.0

@export_group("Visuals")
@export var projectile_scene: PackedScene # The .tscn to spawn
@export var shoot_sound: AudioStream
