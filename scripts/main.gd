extends Control

const BG := Color("#0b1420")
const PANEL := Color("#142233")
const PANEL_HOVER := Color("#20384b")
const ACCENT := Color("#42c6b5")
const TEXT := Color("#edf4f8")
const MUTED := Color("#9aafc2")

var body: VBoxContainer
var page_title: Label
var selected_suspect := 0
var stress := 18
var chat_history: Array[String] = []
var suspects := [
    {"name":"Álvaro Méndez", "job":"Encargado del muelle", "motive":"Disputa económica con Daniel Ortega", "alibi":"Afirma que llegó a casa a las 22:30."},
    {"name":"Lucía Ferrer", "job":"Socia comercial", "motive":"Daniel iba a denunciar un posible fraude", "alibi":"Dice que estuvo en un restaurante."},
    {"name":"Iván Robles", "job":"Guardia de seguridad", "motive":"Fue despedido por la víctima", "alibi":"Asegura que patrullaba el sector norte."}
]
var evidence := [
    {"name":"Informe de escena", "detail":"Daniel Ortega fue encontrado en el Almacén 7 a las 23:40. Sin signos claros de entrada forzada."},
    {"name":"Registro de llamadas", "detail":"Llamada entrante de cuatro minutos a las 22:58 desde un número prepago."},
    {"name":"Cámara del muelle", "detail":"Una figura con chaqueta clara aparece cerca del almacén a las 23:17."},
    {"name":"Informe médico", "detail":"Intervalo estimado de muerte: entre las 23:10 y las 23:35."},
    {"name":"Huella parcial", "detail":"Fragmento recuperado del pomo interior. La muestra no permite identificación concluyente."}
]

func _ready() -> void:
    _build_ui()
    open_page("Inicio")

func _style(color: Color, radius := 9) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.corner_radius_top_left = radius
    s.corner_radius_top_right = radius
    s.corner_radius_bottom_left = radius
    s.corner_radius_bottom_right = radius
    s.content_margin_left = 12
    s.content_margin_right = 12
    s.content_margin_top = 8
    s.content_margin_bottom = 8
    return s

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = BG
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 0)
    add_child(root)

    var top := HBoxContainer.new()
    top.custom_minimum_size.y = 54
    top.add_theme_constant_override("separation", 14)
    root.add_child(top)
    var brand := Label.new()
    brand.text = "▣  UNIDAD DE HOMICIDIOS  /  SISTEMA INTERNO"
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    brand.add_theme_color_override("font_color", ACCENT)
    brand.add_theme_font_size_override("font_size", 17)
    top.add_child(brand)
    var date := Label.new()
    date.text = "RAVENPORT  •  TURNO NOCHE"
    date.add_theme_color_override("font_color", MUTED)
    top.add_child(date)

    var separator := ColorRect.new()
    separator.color = Color("#26394b")
    separator.custom_minimum_size.y = 1
    root.add_child(separator)

    var main_row := HBoxContainer.new()
    main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_row.add_theme_constant_override("separation", 0)
    root.add_child(main_row)

    var nav := VBoxContainer.new()
    nav.custom_minimum_size.x = 218
    nav.add_theme_constant_override("separation", 6)
    main_row.add_child(nav)
    var nav_label := Label.new()
    nav_label.text = "  TERMINAL"
    nav_label.add_theme_color_override("font_color", MUTED)
    nav.add_child(nav_label)
    for name in ["Inicio", "Expedientes", "Interrogatorios", "Laboratorio", "Tablero", "Correo", "Patrullas", "Asuntos Internos"]:
        var button := Button.new()
        button.text = "   " + name
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.custom_minimum_size.y = 43
        button.add_theme_stylebox_override("normal", _style(PANEL))
        button.add_theme_stylebox_override("hover", _style(PANEL_HOVER))
        button.add_theme_color_override("font_color", TEXT)
        button.pressed.connect(func(): open_page(name))
        nav.add_child(button)

    var content := VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    main_row.add_child(content)
    page_title = Label.new()
    page_title.add_theme_font_size_override("font_size", 26)
    page_title.add_theme_color_override("font_color", TEXT)
    content.add_child(page_title)
    var accent_line := ColorRect.new()
    accent_line.color = ACCENT
    accent_line.custom_minimum_size.y = 2
    content.add_child(accent_line)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 10)
    scroll.add_child(body)

    var footer := Label.new()
    footer.text = "● SISTEMA LOCAL ACTIVO   |   SIN CONEXIÓN EXTERNA   |   EXPEDIENTE RPD-026-114"
    footer.custom_minimum_size.y = 28
    footer.add_theme_color_override("font_color", ACCENT)
    footer.add_theme_font_size_override("font_size", 11)
    root.add_child(footer)

func _card(title: String, description: String) -> void:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", _style(PANEL, 11))
    body.add_child(panel)
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 5)
    panel.add_child(col)
    var heading := Label.new()
    heading.text = title
    heading.add_theme_color_override("font_color", ACCENT)
    heading.add_theme_font_size_override("font_size", 16)
    col.add_child(heading)
    var detail := Label.new()
    detail.text = description
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_color_override("font_color", TEXT)
    col.add_child(detail)

func _button(label: String, action: Callable) -> void:
    var b := Button.new()
    b.text = label
    b.custom_minimum_size.y = 42
    b.add_theme_stylebox_override("normal", _style(PANEL_HOVER))
    b.add_theme_color_override("font_color", TEXT)
    b.pressed.connect(action)
    body.add_child(b)

func open_page(page: String) -> void:
    page_title.text = page.to_upper()
    for child in body.get_children():
        child.queue_free()
    match page:
        "Inicio":
            _card("BUENAS NOCHES, INSPECTOR", "Terminal de investigación de la Unidad de Homicidios. Hay un expediente prioritario pendiente.")
            _card("CASO ACTIVO  •  RPD-026-114", "Muerte en el Almacén 7\nVíctima: Daniel Ortega, 42 años\nEstado: Investigación abierta")
            _card("ESTADO PROFESIONAL", "Rango: Inspector   |   Saldo: 1.850 créditos   |   Reputación: 72/100")
            _button("Abrir expediente", func(): open_page("Expedientes"))
            _button("Iniciar interrogatorios", func(): open_page("Interrogatorios"))
        "Expedientes":
            _card("RPD-026-114  |  MUERTE EN EL ALMACÉN 7", "Aviso recibido: 23:40\nLugar: Distrito portuario, Almacén 7\nResponsable: tú")
            for item in evidence:
                _card("PRUEBA  •  " + item.name, item.detail)
            _card("PERSONAS DE INTERÉS", "Álvaro Méndez, Lucía Ferrer e Iván Robles. Sus declaraciones y coartadas pueden contrastarse con las pruebas.")
        "Interrogatorios":
            _show_interrogation()
        "Laboratorio":
            _card("LABORATORIO FORENSE", "Las pruebas deben examinarse y sus resultados añadirse al expediente.")
            _card("HUELLA PARCIAL", "Siete puntos característicos aprovechables. Hace falta una muestra de referencia para comparar.")
            _button("Analizar cronología", func(): _card("CRONOLOGÍA", "22:58 — llamada entrante.\n23:10–23:35 — intervalo estimado de muerte.\n23:17 — figura captada por cámara."))
            _button("Validar informe preliminar", func(): _card("RESULTADO", "Informe preliminar guardado en el expediente. No constituye una identificación concluyente."))
        "Tablero":
            _card("TABLERO DE INVESTIGACIÓN", "Conecta indicios para construir hipótesis. Una conexión lógica no equivale por sí sola a prueba judicial.")
            _card("LÍNEA TEMPORAL", "22:58 llamada → 23:17 figura en cámara → 23:10–23:35 intervalo médico → 23:40 hallazgo.")
            _button("Guardar deducción provisional", func(): _card("DEDUCCIÓN GUARDADA", "Hipótesis añadida a tus notas. Todavía no hay fundamento suficiente para solicitar una detención."))
        "Correo":
            _card("COMISARIO VEGA  •  00:12", "Necesito un informe preliminar del caso RPD-026-114 antes de las 08:00. No quiero una detención precipitada.")
            _card("LABORATORIO  •  00:26", "La huella parcial ha sido digitalizada. La comparación requiere muestras de referencia.")
        "Patrullas":
            _card("CENTRO DE DESPACHO", "Gestiona recursos y solicita comprobaciones en el distrito portuario.")
            _button("Enviar patrulla al Almacén 7", func(): _card("UNIDAD DESPACHADA", "Unidad P-12 asignada. Tiempo estimado de llegada: seis minutos."))
            _button("Solicitar cámaras municipales", func(): _card("SOLICITUD REGISTRADA", "Se ha solicitado copia de las cámaras del sector portuario."))
        "Asuntos Internos":
            _card("EXPEDIENTE PROFESIONAL", "Reputación: 72/100\nIncidencias: 0\nAdvertencias: 0\nEstado: sin investigaciones abiertas.")
            _card("AVISO DE PROCEDIMIENTO", "Las detenciones sin fundamento, alteraciones de pruebas y vulneraciones de derechos pueden abrir una investigación interna.")

func _show_interrogation() -> void:
    var suspect := suspects[selected_suspect]
    var selector := HBoxContainer.new()
    selector.add_theme_constant_override("separation", 6)
    body.add_child(selector)
    for i in range(suspects.size()):
        var index := i
        var b := Button.new()
        b.text = suspects[i].name
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.add_theme_stylebox_override("normal", _style(PANEL_HOVER))
        b.add_theme_color_override("font_color", TEXT)
        b.pressed.connect(func(): selected_suspect = index; open_page("Interrogatorios"))
        selector.add_child(b)
    suspect = suspects[selected_suspect]
    _card("DECLARACIÓN  •  " + suspect.name, suspect.job + "\nMotivo conocido: " + suspect.motive + "\nCoartada: " + suspect.alibi)
    var tension := ProgressBar.new()
    tension.max_value = 100
    tension.value = stress
    tension.custom_minimum_size.y = 18
    body.add_child(tension)
    var transcript := RichTextLabel.new()
    transcript.bbcode_enabled = true
    transcript.fit_content = true
    transcript.custom_minimum_size.y = 135
    transcript.add_theme_stylebox_override("normal", _style(Color("#0d1b29")))
    transcript.text = "[color=#42c6b5]SISTEMA:[/color] Interrogatorio iniciado. Formula preguntas y contrasta respuestas con las pruebas.\n"
    for line in chat_history:
        transcript.append_text(line + "\n")
    body.add_child(transcript)
    var question := LineEdit.new()
    question.placeholder_text = "Escribe una pregunta..."
    question.custom_minimum_size.y = 46
    body.add_child(question)
    var proof := OptionButton.new()
    proof.add_item("No presentar prueba")
    for item in evidence:
        proof.add_item(item.name)
    body.add_child(proof)
    _button("Enviar pregunta", func(): _send_question(question.text, proof.selected, transcript))

func _send_question(raw: String, proof_index: int, transcript: RichTextLabel) -> void:
    var question := raw.strip_edges()
    if question.is_empty():
        return
    var suspect: Dictionary = suspects[selected_suspect]
    var q := question.to_lower()
    var answer := ""
    if proof_index > 0:
        var proof_name: String = evidence[proof_index - 1].name
        stress = min(100, stress + 12)
        if proof_name == "Cámara del muelle":
            answer = "No recuerdo haber estado allí a esa hora. Esa imagen no demuestra quién aparece."
        elif proof_name == "Registro de llamadas":
            answer = "No sé nada de esa llamada. Tendrá que averiguar a quién pertenece el número."
        elif proof_name == "Informe médico":
            answer = "No soy médico. No puedo decirle cuándo ocurrió."
        elif proof_name == "Huella parcial":
            answer = "Una huella incompleta no demuestra que alguien haya cometido un asesinato."
        else:
            answer = "Ese informe no demuestra que yo estuviera implicado."
    elif q.contains("dónde") or q.contains("donde") or q.contains("coartada") or q.contains("hora"):
        answer = "Ya se lo he dicho: " + suspect.alibi + " No tengo nada más que añadir."
    elif q.contains("víctima") or q.contains("victima") or q.contains("daniel") or q.contains("relación") or q.contains("relacion"):
        answer = "Conocía a Daniel, como todos en el muelle. Eso no significa que quisiera hacerle daño."
    elif q.contains("motivo") or q.contains("dinero") or q.contains("deuda") or q.contains("por qué"):
        answer = "Tuvimos desacuerdos, pero nada que no pudiera resolverse hablando."
    elif q.contains("mentira") or q.contains("miente") or q.contains("contradicción") or q.contains("contradiccion"):
        stress = min(100, stress + 9)
        answer = "No estoy mintiendo. Si cree que hay una contradicción, tendrá que demostrarla."
    else:
        answer = "No entiendo qué intenta insinuar. Haga una pregunta más concreta, inspector."
    if stress >= 75:
        answer += " Parece perder la paciencia y solicita hablar con un abogado."
    chat_history.append("[color=#9aafc2]TÚ:[/color] " + question)
    chat_history.append("[color=#edf4f8]" + suspect.name.to_upper() + ":[/color] " + answer)
    open_page("Interrogatorios")
