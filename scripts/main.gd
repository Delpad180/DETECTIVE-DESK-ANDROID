extends Control

func _ready() -> void:
    get_viewport().transparent_bg = false
    RenderingServer.set_default_clear_color(Color("#101c2b"))
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var panel := ColorRect.new()
    panel.color = Color("#101c2b")
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(panel)

    var title := Label.new()
    title.text = "DETECTIVE DESK"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    title.add_theme_color_override("font_color", Color("#42c6b5"))
    title.add_theme_font_size_override("font_size", 34)
    add_child(title)

    var subtitle := Label.new()
    subtitle.text = "PRUEBA DE PANTALLA ANDROID\\nSi puedes leer este mensaje, el motor gráfico funciona."
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    subtitle.position = Vector2(0, 70)
    subtitle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    subtitle.add_theme_color_override("font_color", Color("#edf4f8"))
    subtitle.add_theme_font_size_override("font_size", 18)
    add_child(subtitle)

    var marker := Label.new()
    marker.text = "DIAGNOSTICO 01"
    marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    marker.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    marker.add_theme_color_override("font_color", Color("#9aafc2"))
    add_child(marker)
