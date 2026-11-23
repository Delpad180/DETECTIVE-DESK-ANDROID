extends Control

const BG := Color("#0b1420")
const PANEL := Color("#142233")
const PANEL_HOVER := Color("#20384b")
const ACCENT := Color("#42c6b5")
const TEXT := Color("#edf4f8")
const MUTED := Color("#9aafc2")
const WARNING := Color("#e6b86a")
const SAVE_PATH := "user://detective_desk_save.cfg"

var body: VBoxContainer
var page_title: Label
var selected_suspect := 0
var current_page := "Inicio"
var stress := [18, 18, 18]
var chats: Array = [[], [], []]
var examined_ids: Array[String] = []
var deductions: Array[String] = []
var case_notes: Array[String] = []
var case_closed := false

var suspects := [
    {"id":"alvaro", "name":"Álvaro Méndez", "job":"Encargado del muelle", "motive":"Disputa económica con Daniel Ortega", "alibi":"Afirma que llegó a casa a las 22:30.", "profile":"Conocía los horarios de carga y tenía acceso habitual al almacén.", "style":"Responde con seguridad y evita hablar de sus cuentas."},
    {"id":"lucia", "name":"Lucía Ferrer", "job":"Socia comercial", "motive":"Daniel iba a denunciar un posible fraude", "alibi":"Dice que estuvo en un restaurante.", "profile":"Mantenía negocios con la víctima y conocía sus movimientos financieros.", "style":"Mide sus palabras y pide que las preguntas sean concretas."},
    {"id":"ivan", "name":"Iván Robles", "job":"Guardia de seguridad", "motive":"Fue despedido por la víctima", "alibi":"Asegura que patrullaba el sector norte.", "profile":"Conocía los puntos ciegos del sistema de vigilancia.", "style":"Se muestra a la defensiva cuando se cuestiona su trabajo."}
]

var evidence := [
    {"id":"scene", "name":"Informe de escena", "detail":"Daniel Ortega fue encontrado en el Almacén 7 a las 23:40. No se aprecian signos claros de entrada forzada.", "analysis":"El acceso pudo realizarse con llave, autorización o por una entrada sin daños visibles. No identifica al autor.", "category":"Escena"},
    {"id":"calls", "name":"Registro de llamadas", "detail":"Llamada entrante de cuatro minutos a las 22:58 desde un número prepago.", "analysis":"El registro confirma la comunicación, pero todavía no identifica al titular ni el contenido de la llamada.", "category":"Telecomunicaciones"},
    {"id":"camera", "name":"Cámara del muelle", "detail":"Una figura con chaqueta clara aparece cerca del almacén a las 23:17. La imagen no permite reconocer el rostro.", "analysis":"La presencia de una figura es compatible con el intervalo médico, pero no permite identificarla.", "category":"Vídeo"},
    {"id":"medical", "name":"Informe médico", "detail":"Intervalo estimado de muerte: entre las 23:10 y las 23:35.", "analysis":"La estimación sitúa la muerte en una ventana de 25 minutos. Es una aproximación pericial, no una hora exacta.", "category":"Medicina forense"},
    {"id":"print", "name":"Huella parcial", "detail":"Fragmento recuperado del pomo interior. La muestra no permite una identificación concluyente.", "analysis":"La huella necesita una muestra de referencia y un análisis comparativo. No permite atribución individual por sí sola.", "category":"Dactiloscopia"}
]

func _ready() -> void:
    _load_game()
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
    s.content_margin_top = 9
    s.content_margin_bottom = 9
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
    top.custom_minimum_size.y = 58
    top.add_theme_constant_override("separation", 12)
    root.add_child(top)
    var brand := Label.new()
    brand.text = "▣  UNIDAD DE HOMICIDIOS  /  SISTEMA INTERNO"
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    brand.add_theme_color_override("font_color", ACCENT)
    brand.add_theme_font_size_override("font_size", 16)
    top.add_child(brand)
    var status := Label.new()
    status.text = "RAVENPORT  •  TURNO NOCHE"
    status.add_theme_color_override("font_color", MUTED)
    status.add_theme_font_size_override("font_size", 11)
    top.add_child(status)

    var separator := ColorRect.new()
    separator.color = Color("#26394b")
    separator.custom_minimum_size.y = 1
    root.add_child(separator)

    var main_row := HBoxContainer.new()
    main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_row.add_theme_constant_override("separation", 0)
    root.add_child(main_row)

    var nav_scroll := ScrollContainer.new()
    nav_scroll.custom_minimum_size.x = 205
    nav_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_row.add_child(nav_scroll)
    var nav := VBoxContainer.new()
    nav.add_theme_constant_override("separation", 6)
    nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    nav_scroll.add_child(nav)
    var nav_label := Label.new()
    nav_label.text = "  TERMINAL"
    nav_label.add_theme_color_override("font_color", MUTED)
    nav.add_child(nav_label)
    for page in ["Inicio", "Expedientes", "Interrogatorios", "Laboratorio", "Tablero", "Correo", "Patrullas", "Asuntos Internos"]:
        var page_name: String = page
        var button := Button.new()
        button.text = "   " + page_name
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.custom_minimum_size.y = 48
        button.add_theme_stylebox_override("normal", _style(PANEL))
        button.add_theme_stylebox_override("hover", _style(PANEL_HOVER))
        button.add_theme_color_override("font_color", TEXT)
        button.pressed.connect(func(): open_page(page_name))
        nav.add_child(button)

    var content := VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 8)
    main_row.add_child(content)
    page_title = Label.new()
    page_title.add_theme_font_size_override("font_size", 25)
    page_title.add_theme_color_override("font_color", TEXT)
    content.add_child(page_title)
    var accent_line := ColorRect.new()
    accent_line.color = ACCENT
    accent_line.custom_minimum_size.y = 2
    content.add_child(accent_line)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 10)
    scroll.add_child(body)

    var footer := Label.new()
    footer.text = "● PROGRESO LOCAL   |   EXPEDIENTE RPD-026-114   |   AUTOGUARDADO"
    footer.custom_minimum_size.y = 28
    footer.add_theme_color_override("font_color", ACCENT)
    footer.add_theme_font_size_override("font_size", 10)
    root.add_child(footer)

func _card(title: String, description: String, color := PANEL) -> void:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", _style(color, 11))
    body.add_child(panel)
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 5)
    panel.add_child(col)
    var heading := Label.new()
    heading.text = title
    heading.add_theme_color_override("font_color", ACCENT)
    heading.add_theme_font_size_override("font_size", 16)
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    col.add_child(heading)
    var detail := Label.new()
    detail.text = description
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_color_override("font_color", TEXT)
    col.add_child(detail)

func _button(label: String, action: Callable, parent: Control = null) -> void:
    var b := Button.new()
    b.text = label
    b.custom_minimum_size.y = 46
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_stylebox_override("normal", _style(PANEL_HOVER))
    b.add_theme_stylebox_override("hover", _style(Color("#2a4a5e")))
    b.add_theme_color_override("font_color", TEXT)
    b.pressed.connect(action)
    if parent == null:
        body.add_child(b)
    else:
        parent.add_child(b)

func _clear_body() -> void:
    for child in body.get_children():
        child.queue_free()

func open_page(page: String) -> void:
    current_page = page
    page_title.text = page.to_upper()
    _clear_body()
    match page:
        "Inicio":
            _page_home()
        "Expedientes":
            _page_case()
        "Interrogatorios":
            _page_interrogation()
        "Laboratorio":
            _page_lab()
        "Tablero":
            _page_board()
        "Correo":
            _page_mail()
        "Patrullas":
            _page_patrols()
        "Asuntos Internos":
            _page_internal()

func _page_home() -> void:
    _card("BUENAS NOCHES, INSPECTOR", "Terminal de investigación de la Unidad de Homicidios. Revisa las pruebas, entrevista a las personas de interés y documenta cada deducción.")
    _card("CASO ACTIVO  •  RPD-026-114", "Muerte en el Almacén 7\nVíctima: Daniel Ortega, 42 años\nEstado: " + ("Cerrado" if case_closed else "Investigación abierta"))
    _card("RESUMEN DE INVESTIGACIÓN", "Pruebas examinadas: %d/%d\nDeducciones registradas: %d\nPersonas entrevistadas: %d/3" % [examined_ids.size(), evidence.size(), deductions.size(), _count_interviewed()])
    _button("Continuar expediente", func(): open_page("Expedientes"))
    _button("Ir a interrogatorios", func(): open_page("Interrogatorios"))
    _button("Guardar partida ahora", func(): _save_game(); _card("PARTIDA GUARDADA", "El progreso se ha guardado en el almacenamiento local de esta instalación."))

func _page_case() -> void:
    _card("RPD-026-114  |  MUERTE EN EL ALMACÉN 7", "Aviso recibido: 23:40\nLugar: Distrito portuario, Almacén 7\nVíctima: Daniel Ortega\nEstado: " + ("Cerrado" if case_closed else "Abierto"))
    _card("INSTRUCCIONES", "Abre cada prueba para examinarla. El análisis queda registrado en el expediente. No confundas una sospecha con una conclusión probada.")
    for item in evidence:
        var item_id: String = item.id
        var state := "EXAMINADA" if examined_ids.has(item_id) else "PENDIENTE"
        _button(("✓  " if examined_ids.has(item_id) else "＋  ") + item.name + "  ·  " + state, func(): _examine_evidence(item_id))
    _card("PERSONAS DE INTERÉS", "Álvaro Méndez — Encargado del muelle\nLucía Ferrer — Socia comercial\nIván Robles — Guardia de seguridad")
    _button("Abrir tablero de deducciones", func(): open_page("Tablero"))

func _examine_evidence(item_id: String) -> void:
    var index := _evidence_index(item_id)
    if index < 0:
        return
    var item: Dictionary = evidence[index]
    if not examined_ids.has(item_id):
        examined_ids.append(item_id)
        _save_game()
    _clear_body()
    page_title.text = "ANÁLISIS DE PRUEBA"
    _card(item.name.to_upper(), item.detail)
    _card("RESULTADO DEL EXAMEN  •  " + item.category.to_upper(), item.analysis)
    _card("VALOR PROBATORIO", "Esta pieza debe valorarse junto con el resto de indicios. El examen no atribuye por sí mismo responsabilidad penal.")
    _button("Volver al expediente", func(): open_page("Expedientes"))
    _button("Ir al tablero", func(): open_page("Tablero"))

func _page_interrogation() -> void:
    _card("SALA DE ENTREVISTAS", "Selecciona a una persona. Cada conversación conserva su historial y nivel de tensión durante la partida.")
    var selector := VBoxContainer.new()
    selector.add_theme_constant_override("separation", 5)
    body.add_child(selector)
    for i in range(suspects.size()):
        var idx := i
        var person: Dictionary = suspects[idx]
        _button(person.name + "  ·  " + person.job, func(): selected_suspect = idx; _show_interview(idx), selector)
    _show_interview(selected_suspect)

func _show_interview(index: int) -> void:
    selected_suspect = index
    var suspect: Dictionary = suspects[index]
    _card("DECLARACIÓN  •  " + suspect.name.to_upper(), suspect.job + "\nMotivo conocido: " + suspect.motive + "\nCoartada: " + suspect.alibi + "\nPerfil: " + suspect.profile)
    var stress_label := Label.new()
    stress_label.text = "TENSIÓN DEL ENTREVISTADO  ·  %d%%" % stress[index]
    stress_label.add_theme_color_override("font_color", WARNING if stress[index] >= 65 else MUTED)
    body.add_child(stress_label)
    var bar := ProgressBar.new()
    bar.max_value = 100
    bar.value = stress[index]
    bar.custom_minimum_size.y = 18
    body.add_child(bar)

    var transcript := VBoxContainer.new()
    transcript.add_theme_constant_override("separation", 4)
    body.add_child(transcript)
    var history: Array = chats[index]
    if history.is_empty():
        _chat_line(transcript, "SISTEMA", "Entrevista iniciada. Formula preguntas concretas o presenta una prueba examinada.")
    else:
        for entry in history:
            _chat_line(transcript, str(entry.role), str(entry.text))

    var question := LineEdit.new()
    question.placeholder_text = "Escribe una pregunta..."
    question.custom_minimum_size.y = 48
    body.add_child(question)
    var proof := OptionButton.new()
    proof.add_item("No presentar prueba", 0)
    for item in evidence:
        if examined_ids.has(item.id):
            proof.add_item(item.name, _evidence_index(item.id) + 1)
    proof.custom_minimum_size.y = 44
    body.add_child(proof)
    _button("Enviar pregunta", func(): _send_question(index, question.text, proof.get_selected_id()))
    _button("Finalizar entrevista", func(): _add_note("Entrevista con " + suspect.name + " finalizada. Tensión: " + str(stress[index]) + "%"); open_page("Expedientes"))

func _chat_line(parent: Control, speaker: String, message: String) -> void:
    var label := Label.new()
    label.text = speaker + ": " + message
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_color_override("font_color", ACCENT if speaker == "INSPECTOR" else TEXT)
    parent.add_child(label)

func _send_question(index: int, raw: String, proof_id: int) -> void:
    var question := raw.strip_edges()
    if question.is_empty():
        return
    var suspect: Dictionary = suspects[index]
    var q := question.to_lower()
    var answer := ""
    var pressure := 5

    if proof_id > 0:
        var item: Dictionary = evidence[proof_id - 1]
        pressure = 12
        match item.id:
            "camera":
                answer = "La imagen no muestra una cara. No puede asegurar que sea yo quien aparece."
            "calls":
                answer = "No reconozco ese número. Tendrá que averiguar quién lo utilizaba."
            "medical":
                answer = "Ese intervalo es amplio. No demuestra dónde estaba yo."
            "print":
                answer = "Una huella parcial sin identificar no demuestra quién estuvo allí."
            "scene":
                answer = "Que no haya daños en la puerta no significa que yo entrara en el almacén."
    elif q.contains("coartada") or q.contains("dónde") or q.contains("donde") or q.contains("hora") or q.contains("23:") or q.contains("22:"):
        answer = suspect.alibi + " Mantengo lo que declaré."
        pressure = 8
    elif q.contains("daniel") or q.contains("víctima") or q.contains("victima") or q.contains("relación") or q.contains("relacion"):
        answer = "Conocía a Daniel por motivos de trabajo. Nuestra relación no era siempre fácil, pero eso no significa que quisiera hacerle daño."
    elif q.contains("motivo") or q.contains("dinero") or q.contains("deuda") or q.contains("fraude"):
        answer = suspect.motive + ". Hubo desacuerdos, pero no voy a aceptar que eso me convierta en sospechoso de un homicidio."
        pressure = 9
    elif q.contains("llamada") or q.contains("teléfono") or q.contains("telefono") or q.contains("número") or q.contains("numero"):
        answer = "No puedo identificar esa llamada. El registro no indica quién tenía el teléfono en la mano."
    elif q.contains("cámara") or q.contains("camara") or q.contains("figura") or q.contains("chaqueta"):
        answer = "La grabación no permite reconocer a la persona. No voy a especular sobre una silueta."
    elif q.contains("huella") or q.contains("pomo"):
        answer = "La muestra es parcial. Espere al resultado comparativo antes de sacar conclusiones."
    elif q.contains("miente") or q.contains("mentira") or q.contains("contradic"):
        answer = "No estoy mintiendo. Si tiene una contradicción concreta, enséñemela."
        pressure = 14
    elif q.contains("abogado") or q.contains("descansar"):
        answer = "Quiero que conste que estoy dispuesto a continuar, pero no responderé a preguntas que no entienda."
        pressure = 0
    else:
        answer = "No entiendo qué intenta insinuar. Haga una pregunta más concreta, inspector."

    stress[index] = clampi(stress[index] + pressure, 0, 100)
    if stress[index] >= 80:
        answer += " Estoy perdiendo la paciencia. Quiero que conste mi protesta y solicito asistencia letrada."
    chats[index].append({"role":"INSPECTOR", "text":question})
    chats[index].append({"role":suspect.name.to_upper(), "text":answer})
    _add_note("Pregunta a " + suspect.name + ": " + question)
    _save_game()
    open_page("Interrogatorios")

func _page_lab() -> void:
    _card("LABORATORIO FORENSE", "Solicita análisis complementarios. Los resultados se incorporan al expediente como información provisional.")
    for item in evidence:
        if examined_ids.has(item.id):
            _card(item.name.to_upper(), item.analysis)
    if not examined_ids.has("print"):
        _card("MUESTRA PENDIENTE", "Examina primero la huella parcial en el expediente.")
    _button("Preparar solicitud de comparación de huellas", func(): _lab_fingerprint())
    _button("Reconstruir cronología", func(): _lab_timeline())

func _lab_fingerprint() -> void:
    if not examined_ids.has("print"):
        _card("SOLICITUD NO DISPONIBLE", "Debes examinar primero la huella parcial.")
        return
    _add_note("Laboratorio: solicitada comparación de huella parcial. Pendiente de muestra de referencia.")
    _card("SOLICITUD REGISTRADA", "La comparación queda pendiente de una muestra de referencia válida. No se ha identificado a ninguna persona.")
    _save_game()

func _lab_timeline() -> void:
    var lines := "22:58 — llamada entrante de número prepago.\n23:10–23:35 — intervalo médico estimado.\n23:17 — figura captada cerca del almacén.\n23:40 — hallazgo del cuerpo."
    if not examined_ids.has("calls") or not examined_ids.has("medical") or not examined_ids.has("camera"):
        lines += "\n\nFaltan pruebas por examinar. La cronología está incompleta."
    else:
        lines += "\n\nLas tres referencias temporales están examinadas. La secuencia es compatible, pero no determina quién realizó la llamada ni quién aparece en cámara."
    _card("CRONOLOGÍA PROVISIONAL", lines)
    _add_note("Se reconstruyó la cronología con los registros disponibles.")
    _save_game()

func _page_board() -> void:
    _card("TABLERO DE INVESTIGACIÓN", "Relaciona hechos documentados. Una conexión es una hipótesis de trabajo, no una prueba autónoma de culpabilidad.")
    _card("LÍNEA TEMPORAL", "22:58 llamada → 23:17 figura en cámara → 23:10–23:35 intervalo médico → 23:40 hallazgo.")
    _card("PRUEBAS EXAMINADAS", "%d de %d pruebas revisadas." % [examined_ids.size(), evidence.size()])
    if examined_ids.has("calls") and examined_ids.has("camera") and examined_ids.has("medical"):
        _button("Registrar deducción: actividad durante el intervalo", func(): _register_deduction("La llamada y la figura de cámara deben investigarse dentro del intervalo médico. No identifican al autor."))
    else:
        _card("DEDUCCIÓN BLOQUEADA", "Examina el registro de llamadas, la cámara del muelle y el informe médico para desbloquear esta conexión.")
    if examined_ids.has("scene") and examined_ids.has("print"):
        _button("Registrar deducción: acceso al almacén", func(): _register_deduction("La ausencia de daños visibles y la huella parcial justifican investigar quién tenía acceso al almacén. No identifican a una persona."))
    else:
        _card("DEDUCCIÓN BLOQUEADA", "Examina el informe de escena y la huella parcial para investigar el acceso.")
    if deductions.is_empty():
        _card("NOTAS DEL INVESTIGADOR", "Todavía no has registrado deducciones.")
    else:
        for item in deductions:
            _card("DEDUCCIÓN REGISTRADA", item)
    if case_notes.size() > 0:
        _card("ÚLTIMAS NOTAS", "\n".join(case_notes.slice(maxi(0, case_notes.size() - 5), case_notes.size())))

func _register_deduction(note: String) -> void:
    if deductions.has(note):
        _card("YA REGISTRADA", "Esta deducción ya figura en el tablero.")
        return
    deductions.append(note)
    _add_note(note)
    _save_game()
    _card("DEDUCCIÓN AÑADIDA", note)

func _page_mail() -> void:
    _card("COMISARIO VEGA  •  00:12", "Necesito un informe preliminar del caso RPD-026-114 antes de las 08:00. No quiero una detención precipitada.")
    _card("LABORATORIO  •  00:26", "La huella parcial ha sido digitalizada. La comparación requiere muestras de referencia.")
    _card("SISTEMA  •  MENSAJE AUTOMÁTICO", "Los cambios del expediente se guardan localmente. No se envían datos a servidores externos.")

func _page_patrols() -> void:
    _card("CENTRO DE DESPACHO", "Gestiona comprobaciones en el distrito portuario. Las acciones quedan reflejadas en tus notas.")
    _button("Enviar patrulla al Almacén 7", func(): _patrol_action("Unidad P-12 asignada al Almacén 7. Se solicita preservar el perímetro y registrar entradas."))
    _button("Solicitar cámaras municipales", func(): _patrol_action("Solicitud enviada para obtener cámaras municipales del sector portuario. Pendiente de respuesta."))
    _button("Localizar titular del número prepago", func(): _patrol_action("Solicitud de identificación del titular del número prepago registrada. Pendiente de autorización y respuesta del operador."))

func _patrol_action(message: String) -> void:
    _add_note(message)
    _save_game()
    _card("ORDEN REGISTRADA", message)

func _page_internal() -> void:
    _card("EXPEDIENTE PROFESIONAL", "Reputación: 72/100\nIncidencias: 0\nAdvertencias: 0\nEstado: sin investigaciones abiertas.")
    _card("PROTOCOLO DE ACTUACIÓN", "Documenta la procedencia de cada prueba, respeta los derechos de las personas entrevistadas y evita detenciones sin indicios suficientes.")
    _button("Cerrar caso (requiere todas las pruebas)", func(): _attempt_close_case())
    if case_closed:
        _card("CASO CERRADO", "El expediente está marcado como cerrado en esta partida.")

func _attempt_close_case() -> void:
    if examined_ids.size() < evidence.size() or deductions.size() < 1:
        _card("CIERRE NO AUTORIZADO", "Debes examinar todas las pruebas y registrar al menos una deducción. La investigación sigue abierta.")
        return
    case_closed = true
    _save_game()
    _card("CIERRE ADMINISTRATIVO", "Has cerrado la fase inicial de investigación y archivado tus deducciones. No se ha declarado culpable a ninguna persona: las pruebas disponibles no bastan para una conclusión definitiva.")

func _add_note(note: String) -> void:
    case_notes.append(note)
    if case_notes.size() > 40:
        case_notes.pop_front()

func _evidence_index(item_id: String) -> int:
    for i in range(evidence.size()):
        if evidence[i].id == item_id:
            return i
    return -1

func _count_interviewed() -> int:
    var count := 0
    for history in chats:
        if not history.is_empty():
            count += 1
    return count

func _save_game() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("case", "examined_ids", examined_ids)
    cfg.set_value("case", "deductions", deductions)
    cfg.set_value("case", "notes", case_notes)
    cfg.set_value("case", "closed", case_closed)
    cfg.set_value("interviews", "chats", chats)
    cfg.set_value("interviews", "stress", stress)
    cfg.set_value("interviews", "selected", selected_suspect)
    var error := cfg.save(SAVE_PATH)
    if error != OK:
        push_warning("No se pudo guardar la partida: " + str(error))

func _load_game() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) != OK:
        return
    examined_ids = cfg.get_value("case", "examined_ids", [])
    deductions = cfg.get_value("case", "deductions", [])
    case_notes = cfg.get_value("case", "notes", [])
    case_closed = cfg.get_value("case", "closed", false)
    chats = cfg.get_value("interviews", "chats", [[], [], []])
    stress = cfg.get_value("interviews", "stress", [18, 18, 18])
    selected_suspect = clampi(int(cfg.get_value("interviews", "selected", 0)), 0, suspects.size() - 1)
    while chats.size() < suspects.size():
        chats.append([])
    while stress.size() < suspects.size():
        stress.append(18)
