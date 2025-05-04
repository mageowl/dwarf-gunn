class_name Game extends Node2D

@export var players = 2
@export var ore_noise: FastNoiseLite
var _game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_map()

func _input(event: InputEvent) -> void:
	if _game_over and event.is_action("restart"):
		_game_over = false
		
		$StartSound.play()
		await $Interface/Transition.fade_out()
		$Interface/GameOverScreen.visible = false
		
		for child in $Objects.get_children():
			child.free()
		
		$CellDamage.clear()
		$Foreground.clear()
		_generate_map()
		
		$Interface/Transition.fade_in()

func _generate_map() -> void:
	ore_noise.seed = randi()
	
	for x in range(0, 40):
		for y in range(0, 30):
			var ore_value := ore_noise.get_noise_2d(x * 8, y * 8)
			var tile := Vector2i(0, 0)
			
			if y + sin(x) + sin(2 * x) > 20:
				if ore_value > 0.5:
					tile = Vector2i(2, 1)
				else:
					tile = Vector2i(2, 0)
			else:
				if ore_value > 0.4:
					tile = Vector2i(0, 1)
				elif ore_value < -0.5:
					tile = Vector2i(1, 1)
			
			$TileMap/Ground.set_cell(Vector2i(x, y), 1, tile)
			$Background.set_cell(Vector2i(x, y), 1, Vector2i(5, 1))
	
	for i in range(players):
		$Interface/GameOverScreen.set_score(i, 0)
		
		var spawn_point = Vector2i(randi_range(1, 12) + (i * 20), randi_range(5, 17))
		for x in range(0, 8):
			for y in range(0, 5):
				if x % 7 == 0 or y % 4 == 0:
					$TileMap/Ground.set_cell(spawn_point + Vector2i(x, y), 1, Vector2i(1, 0))
				else:
					$Background.set_cell(spawn_point + Vector2i(x, y), 1, Vector2i(4, 1))
					$TileMap/Ground.set_cell(spawn_point + Vector2i(x, y))
		var player := preload("res://scene/player/player.tscn").instantiate()
		player.position = Vector2(spawn_point * 8) + Vector2(28, 16)
		player.game = self
		player.input_prefix = "p%d_" % i
		player.score_change.connect(func ():
			$Interface/GameOverScreen.set_score(i, player.score))
		player.death.connect(func ():
			await get_tree().create_timer(0.5).timeout
			_game_over = true
			$Interface/GameOverScreen.visible = true)
		$Objects.add_child(player)

	var secret_room_point = Vector2i(randi_range(1, 34), 24)
	for x in range(0, 5):
		for y in range(0, 5):
			if x % 4 == 0 or y % 4 == 0:
				$TileMap/Ground.set_cell(secret_room_point + Vector2i(x, y), 1, Vector2i(1, 0))
			else:
				$Background.set_cell(secret_room_point + Vector2i(x, y), 1, Vector2i(4, 1))
				$TileMap/Ground.set_cell(secret_room_point + Vector2i(x, y))
	
	var chest := preload("res://scene/chest/chest.tscn").instantiate()
	chest.position = Vector2(secret_room_point * 8) + Vector2(20, 28)
	$Objects.add_child(chest)

func damage_tile(pos: Vector2i, dmg: int) -> int:
	var cell = $TileMap/Ground.get_cell_tile_data(pos)
	if cell == null: return -1
	
	var max_hp: int = cell.get_custom_data("max_hp")
	var unit := max_hp / 3.0
	if dmg < unit: return 0
	
	var current_damage: int = $CellDamage.get_cell_atlas_coords(pos).x
	current_damage += floori(dmg / unit)
	
	var atlas_type: Vector2i = $TileMap/Ground.get_cell_atlas_coords(pos)
	var tile_type := float(atlas_type.y * 8 + atlas_type.x)
	var particle_pos := Vector2(pos * 8) + Vector2(0.5, 0.5)
	var flags := GPUParticles2D.EMIT_FLAG_POSITION + GPUParticles2D.EMIT_FLAG_CUSTOM
	$BreakParticles.emit_particle(Transform2D(0, particle_pos), Vector2.ZERO, Color.WHITE, Color(0, 0, tile_type / 8., 1), flags)
	$BreakParticles.emit_particle(Transform2D(0, particle_pos + Vector2(0, 4)), Vector2.ZERO, Color.WHITE, Color(1, 0, tile_type / 64., 1), flags)
	$BreakParticles.emit_particle(Transform2D(0, particle_pos + Vector2(4, 0)), Vector2.ZERO, Color.WHITE, Color(2, 0, tile_type / 64., 1), flags)
	$BreakParticles.emit_particle(Transform2D(0, particle_pos + Vector2(4, 4)), Vector2.ZERO, Color.WHITE, Color(3, 0, tile_type / 64., 1), flags)
	
	if current_damage < 2 and current_damage >= 0:
		$CellDamage.set_cell(pos, 0, Vector2i(current_damage, 0))
		return 0
	elif current_damage >= 2:
		$CellDamage.set_cell(pos)
		$TileMap/Ground.set_cell(pos)
		return cell.get_custom_data("score")
	return 0

func tile_coords(pos: Vector2) -> Vector2i:
	return $TileMap/Ground.local_to_map(pos)
