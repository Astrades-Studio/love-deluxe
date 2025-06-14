## In this singleton will live all the preloads for your game, shaders, scenes, audio streams, etc.
## Just preload once on game initialization and have them available always in the game
class_name Preloader

## Pixel Art UI Layout
const WorldSelectionScene: PackedScene = preload("uid://bleiqd8yjy62p")
const WorldSaveSlotPanelScene: PackedScene = preload("uid://du0kusvolof3y")

#region Levels ---------------------------------------- #

const LevelScene: PackedScene = preload("uid://bfqb614bysg2o")

const VENUS_EARTH = preload("res://resources/levels/1_venus-earth.tres")
const EARTH_MARS = preload("res://resources/levels/2_earth-mars.tres")
const MARS_JUPITER = preload("res://resources/levels/3_mars-jupiter.tres")
const JUPITER_URANUS = preload("res://resources/levels/4_jupiter-uranus.tres")
const URANUS_KUIPER = preload("res://resources/levels/5_uranus_kuiper.tres")

#endregion ---------------------------------------- #


#region Scenes ---------------------------------------- #

const MainMenuScene: PackedScene = preload("uid://75ohsv3f0df6") 
const ShopMenuScene: PackedScene = preload("uid://beikff07mbo6f")


const InitialCutscene : PackedScene = preload("uid://vvxfwyok47jp")
const FinalCutscene : PackedScene = preload("uid://wd6mb4yfou7i")

#endregion ---------------------------------------- #
