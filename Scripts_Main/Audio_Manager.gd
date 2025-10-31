extends Node

var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

func set_music_volume(linear_value: float):
	var volume_db = linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)

func set_sfx_volume(linear_value: float):
	var volume_db = linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(sfx_bus_index, volume_db)

func play_sfx(sound: AudioStream):
	if not sound:
		return
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound
	audio_player.bus = "SFX"
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)
