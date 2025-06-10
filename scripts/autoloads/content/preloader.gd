## In this singleton will live all the preloads for your game, shaders, scenes, audio streams, etc.
## Just preload once on game initialization and have them available always in the game
class_name Preloader

## Pixel Art UI Layout
const WorldSelectionScene: PackedScene = preload("uid://bleiqd8yjy62p")
const WorldSaveSlotPanelScene: PackedScene = preload("uid://du0kusvolof3y")

#region Levels ---------------------------------------- #

const TestLevelScene: PackedScene = preload("uid://bfqb614bysg2o")

#endregion ---------------------------------------- #


#region Scenes ---------------------------------------- #

const MainMenuScene: PackedScene = preload("uid://75ohsv3f0df6") 
const ShopMenuScene: PackedScene = preload("uid://beikff07mbo6f")

#endregion ---------------------------------------- #