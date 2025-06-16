extends Node

#region Viewport
#@onready var SCREEN_SIZE_Y := get_viewport().get_visible_rect().size.y
@onready var BOTTOM_RIGHT := get_viewport().get_visible_rect().size
@onready var BOTTOM_LEFT := Vector2(0.0, BOTTOM_RIGHT.y)
#endregion

#region Levels

var level_dict = {
	1: Preloader.VENUS_EARTH,
	2: Preloader.EARTH_MARS,
	3: Preloader.MARS_JUPITER,
	4: Preloader.JUPITER_URANUS,
	5: Preloader.URANUS_KUIPER
}

enum LevelNumber {
	VENUS_EARTH = 1,
	EARTH_MARS = 2,
	MARS_JUPITER = 3,
	JUPITER_URANUS = 4,
	URANUS_KUIPER = 5
}

var current_level : LevelNumber = LevelNumber.URANUS_KUIPER


func load_next_level():
	if current_level == LevelNumber.URANUS_KUIPER:
		GlobalGameEvents.game_finished.emit()
		SceneTransitionManager.transition_to_scene(Preloader.FinalCutscene)
		return
	current_level += 1
	SceneTransitionManager.transition_to_scene(Preloader.LevelScene)


func load_first_level():
	current_level = LevelNumber.VENUS_EARTH
	SceneTransitionManager.transition_to_scene(Preloader.LevelScene)


func get_next_level_data() -> LevelData:
	if current_level == LevelNumber.URANUS_KUIPER:
		return get_first_level()
	else:
		return level_dict[current_level + 1]


func get_current_level_data() -> LevelData:
	return level_dict[current_level]


func get_first_level() -> LevelData:
	return level_dict[level_dict.keys()[0]]


#endregion


#region Run
var score : int = 0:
	set(new_score):
		score = new_score
		GlobalGameEvents.score_changed.emit(score)

var cash : int = 0:
	set(new_cash):
		score = new_cash
		GlobalGameEvents.cash_changed.emit(cash)
		
var bullets : int = 0:
	set(new_bullets):
		bullets = clamp(new_bullets, 0, 3)
		GlobalGameEvents.bullets_changed.emit(bullets)


func add_fuel(amount: float):
	level.add_fuel(amount)

func add_score(_score: int):
	score += _score

func set_score(_score: int):
	score = _score

var score_at_start : int = 0
func reset_score():
	score = score_at_start

func new_game():
	score = 0
	cash = 0
	bullets = 0
	score_at_start = 0
	current_level = LevelNumber.VENUS_EARTH

func add_bullet():
	bullets += 1



#endregion

#region Level
var level : Level

func get_current_level() -> Level:
	return level
	
func get_current_speed() -> float:
	if !level:
		return 20. # Min speed at start
	return level.speed

func get_current_fuel() -> float:
	if !level:
		return 100.0
	return level.fuel

func get_current_distance() -> int:
	if !level:
		return 0
	return level.get_distance_remaining()

func get_distance_remaining() -> int:
	if !level:
		return 0
	return level.get_distance_remaining()

#endregion


#region Physics layers
const world_collision_layer: int = 1
const player_collision_layer: int = 2
const enemies_collision_layer: int = 4
const hitboxes_collision_layer: int = 8
const shakeables_collision_layer: int = 16
const interactables_collision_layer: int = 32
const grabbables_collision_layer: int = 64
const bullets_collision_layer: int = 128
const playing_cards_collision_layer: int = 256
const ladders_collision_layer: int = 512
#endregion


#region General helpers
## Example with lambda -> Utilities.delay_func(func(): print("test"), 1.5)
## Example with arguments -> Utilities.delay_func(print_text.bind("test"), 2.0)
func delay_func(callable: Callable, time: float, deferred: bool = true):
	if callable.is_valid():
		await wait(time)
		
		if deferred:
			callable.call_deferred()
		else:
			callable.call()

## Example of use: await GameGlobals.wait(1.5)
func wait(seconds: float = 1.0):
	return get_tree().create_timer(seconds).timeout

#endregion
