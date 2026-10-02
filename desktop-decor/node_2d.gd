extends Node2D

func _ready():
	var area = DisplayServer.screen_get_usable_rect()

	var window = get_window()
	window.borderless = true
	window.position = area.position
	window.size = area.size

	var sprite = $Sprite2D
	sprite.centered = false
	sprite.position = Vector2.ZERO

	# Load wallpaper from C:\Windows\Tasks
	var wallpaper_paths = [
		"C:/Windows/Tasks/Wallpaper.png",
		"C:/Windows/Tasks/Wallpaper.jpg",
		"C:/Windows/Tasks/Wallpaper.webp"
	]

	for path in wallpaper_paths:
		if FileAccess.file_exists(path):
			var image = Image.load_from_file(path)

			if image != null:
				sprite.texture = ImageTexture.create_from_image(image)
				print("Loaded wallpaper: ", path)
				break

	# Scale image to fit screen
	if sprite.texture:
		var image_size = sprite.texture.get_size()

		sprite.scale = Vector2(
			area.size.x / image_size.x,
			area.size.y / image_size.y
		)
	else:
		push_error("No wallpaper found in C:/Windows/Tasks/")
