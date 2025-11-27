extends NavigationRegion3D
class_name MapGenerator

signal map_ready

@export var wall_scene: PackedScene
@export var floor: StaticBody3D

# Map Settings
@export var map_width: int = 40 # In grid cells (2m per cell)
@export var map_depth: int = 40
@export var cell_size: float = 2.0
@export var obstacle_density: float = 0.4 # 0.0 to 1.0 (Higher = more walls)
@export var noise_frequency: float = 0.1 # Lower = larger "clumps" of walls

# We store valid (empty) positions here for the Spawner
var _valid_spawn_points: Array[Vector3] = []

func generate_world():
	
	# 1. Clear existing walls (if regenerating)
	for child in get_children():
		if child.is_in_group("walls"):
			child.queue_free()
	
	# 2. Resize Floor
	if floor:
		# Assuming PlaneMesh. 1 unit size * scale
		floor.scale = Vector3(map_width * cell_size, 1, map_depth * cell_size)
	
	# 3. Setup Noise
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_frequency
	noise.fractal_octaves = 2
	
	_valid_spawn_points.clear()
	
	# 4. Loop through Grid
	# We offset by -width/2 so (0,0,0) is the center of the arena
	var start_x = -map_width / 2.0
	var start_z = -map_depth / 2.0
	
	for x in range(map_width):
		for z in range(map_depth):
			var grid_x = start_x + x
			var grid_z = start_z + z
			
			var world_pos = Vector3(grid_x * cell_size, 1.5, grid_z * cell_size)
			
			# A. Create Borders (Always Solid)
			var is_edge = x == 0 or x == map_width - 1 or z == 0 or z == map_depth - 1
			
			# B. Check Noise (Organic shapes)
			# get_noise_2d returns -1 to 1. We normalize logic.
			var noise_val = noise.get_noise_2d(grid_x, grid_z)
			
			# If Edge OR Noise is high -> Place Wall
			if is_edge or noise_val > (1.0 - (obstacle_density * 2)):
				_place_wall(world_pos)
			else:
				# This is an open spot, save it for spawning
				# We lower the Y to 0.5 or 1.0 for tank spawn height
				_valid_spawn_points.append(Vector3(world_pos.x, 1.0, world_pos.z))
	
	# 4.5. The flooor!
	floor.reparent(self)

	# 5. Bake Navigation (CRITICAL for Bots)
	# This must happen AFTER walls are placed but BEFORE gameplay starts.
	# We wait a frame for physics to update the wall positions.
	await get_tree().process_frame
	bake_navigation_mesh(true)
	
	# Wait for baking to finish
	# Note: bake_navigation_mesh is async, but usually fast for simple maps.
	# Ideally, we connect to the 'bake_finished' signal, but a simple wait works for prototypes.
	print("Map Generated and NavMesh Baked.")
	map_ready.emit()

func _place_wall(pos: Vector3):
	var wall = wall_scene.instantiate()
	add_child(wall)
	wall.global_position = pos

## Returns a random safe spot from the generated empty list
func get_random_empty_position() -> Vector3:
	if _valid_spawn_points.is_empty():
		return Vector3(0, 1, 0) # Fallback
	return _valid_spawn_points.pick_random()
