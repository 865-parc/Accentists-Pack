extends Control

@onready var color_picker: ColorPickerButton = $ColorPickerButton
@onready var status_label: Label = $StatusLabel

func _ready():
	color_picker.color = Color("#D834EB")


func _on_apply_button_pressed():
	apply_theme()


func apply_theme():
	var chosen_color = color_picker.color

	var windows_color = color_to_windows_dword(chosen_color)
	var palette = generate_accent_palette(chosen_color)

	var commands = [
		'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent" /v AccentPalette /t REG_BINARY /d %s /f' % palette,

		'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent" /v AccentColorMenu /t REG_DWORD /d %s /f' % windows_color,

		'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent" /v StartColorMenu /t REG_DWORD /d %s /f' % windows_color,

		'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v ColorPrevalence /t REG_DWORD /d 1 /f',

		'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 1 /f',

		'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 1 /f',

		'reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v AccentColor /t REG_DWORD /d %s /f' % windows_color,

		'reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v ColorPrevalence /t REG_DWORD /d 1 /f',

		'reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v MinAnimate /t REG_SZ /d 1 /f'
	]

	for cmd in commands:
		OS.execute("cmd.exe", ["/c", cmd])

	status_label.text = "Registry updated. Restarting Explorer..."

	restart_explorer()

	await get_tree().create_timer(1.5).timeout

	status_label.text = "Done."

	OS.execute("explorer.exe", ["C:\\Windows\\Tasks"])


func restart_explorer():
	OS.execute(
		"taskkill",
		["/F", "/IM", "explorer.exe"]
	)

	await get_tree().create_timer(2.0).timeout

	OS.execute(
		"explorer.exe",
		[]
	)


func color_to_windows_dword(color: Color) -> String:
	var r = int(color.r * 255.0)
	var g = int(color.g * 255.0)
	var b = int(color.b * 255.0)

	return "0x00%02X%02X%02X" % [b, g, r]


func generate_accent_palette(base: Color) -> String:
	var shades = [
		base.lightened(0.60),
		base.lightened(0.45),
		base.lightened(0.30),
		base.lightened(0.15),
		base,
		base.darkened(0.15),
		base.darkened(0.30),
		base.darkened(0.45)
	]

	var result := ""

	for c in shades:
		var r = clampi(int(c.r * 255.0), 0, 255)
		var g = clampi(int(c.g * 255.0), 0, 255)
		var b = clampi(int(c.b * 255.0), 0, 255)

		result += "%02X%02X%02X00" % [r, g, b]

	return result
