func save_game():
    var saved_game: SavedGame = SavedGame.new()
    
    saved_game.player_health = player.health
    saved_game.player_position = player.global_position
    
    ResourceSaver.save(saved_game, "user://savegame.tres")

func load_game():
    var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
    
    player.global_position = saved_game.player_position
    player.health = saved_game.player_health
