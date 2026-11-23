package com.delpad.detectivedesk;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.content.Context;
import android.widget.*;
import android.text.InputType;
import java.util.*;

public class MainActivity extends Activity {
    private final int bg=Color.rgb(8,15,25), panel=Color.rgb(18,31,47), panel2=Color.rgb(25,42,61),
        accent=Color.rgb(55,210,185), white=Color.rgb(237,244,250), muted=Color.rgb(151,174,194),
        danger=Color.rgb(235,104,104), gold=Color.rgb(235,190,94);
    private LinearLayout content, nav;
    private TextView heading, footer;
    private String page="Inicio";
    private int suspect=0;
    private final Set<String> examined=new HashSet<>();
    private final Set<String> unlocked=new HashSet<>();
    private final ArrayList<String> notes=new ArrayList<>();
    private final ArrayList<String> log=new ArrayList<>();
    private final HashMap<Integer,Integer> pressure=new HashMap<>();
    private final HashMap<Integer,Integer> questions=new HashMap<>();
    private final String[] names={"Álvaro Méndez","Lucía Ferrer","Iván Robles"};
    private final String[] roles={"Encargado del muelle","Socia comercial","Guardia de seguridad"};
    private final String[] profiles={
        "38 años · Encargado del muelle · Acceso habitual al almacén. Conocía los horarios de carga y descarga.",
        "34 años · Socia comercial · Mantenía operaciones económicas con Daniel. Su relación se deterioró durante el último mes.",
        "46 años · Guardia de seguridad · Responsable del turno nocturno. Conocía las cámaras y los puntos ciegos."
    };
    private final String[] evidence={"Informe de escena","Registro de llamadas","Cámara del muelle","Informe médico","Huella parcial","Registro de accesos","Correo de Daniel","Plano del almacén"};
    private final String[] details={
        "Daniel Ortega fue encontrado en el Almacén 7 a las 23:40. No se aprecian signos claros de entrada forzada. La posición de varios objetos debe documentarse antes de extraer conclusiones.",
        "Llamada entrante de cuatro minutos a las 22:58 desde un número prepago. El titular no consta en el expediente inicial.",
        "Una figura con chaqueta clara aparece cerca del almacén a las 23:17. La imagen no permite reconocer el rostro. La hora de la cámara debe contrastarse con el registro del sistema.",
        "Intervalo estimado de muerte: entre las 23:10 y las 23:35. Es una estimación, no una hora exacta.",
        "Fragmento recuperado del pomo interior. La muestra es parcial y no permite una identificación concluyente.",
        "El sistema registra una apertura a las 22:51 con credencial de mantenimiento. El extracto disponible no identifica quién llevaba físicamente la tarjeta.",
        "Borrador recuperado: Daniel pide revisar unas cuentas antes del viernes. No se conserva el hilo completo ni el adjunto.",
        "Plano técnico: puerta principal, acceso de servicio y pasillo de cámaras. El punto ciego del pasillo no cubre el interior del almacén."
    };
    private final String[] timeline={"22:51 — Apertura registrada con credencial de mantenimiento","22:58 — Llamada desde número prepago","23:10–23:35 — Intervalo médico estimado","23:17 — Figura captada junto al muelle","23:40 — Hallazgo y aviso a emergencias"};
    private EditText questionInput;

    @Override public void onCreate(Bundle state){
        super.onCreate(state);
        getWindow().setStatusBarColor(bg); getWindow().setNavigationBarColor(bg);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_HIDE_NAVIGATION|View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        examined.addAll(getPreferences(0).getStringSet("examined",new HashSet<>()));
        unlocked.addAll(getPreferences(0).getStringSet("unlocked",new HashSet<>()));
        notes.addAll(getPreferences(0).getStringSet("notes",new HashSet<>()));
        for(int i=0;i<3;i++){pressure.put(i,0);questions.put(i,0);}
        buildShell(); showPage("Inicio");
    }
    private int dp(float n){return (int)(n*getResources().getDisplayMetrics().density+.5f);}
    private GradientDrawable shape(int color,int radius){GradientDrawable d=new GradientDrawable();d.setColor(color);d.setCornerRadius(dp(radius));return d;}
    private TextView text(String s,int size,int color,boolean bold){
        TextView t=new TextView(this);t.setText(s);t.setTextSize(size);t.setTextColor(color);
        if(bold)t.setTypeface(Typeface.DEFAULT,Typeface.BOLD);t.setPadding(dp(12),dp(9),dp(12),dp(9));return t;
    }
    private LinearLayout column(){LinearLayout l=new LinearLayout(this);l.setOrientation(LinearLayout.VERTICAL);return l;}
    private void buildShell(){
        LinearLayout root=column();root.setBackgroundColor(bg);
        LinearLayout top=new LinearLayout(this);top.setGravity(Gravity.CENTER_VERTICAL);top.setPadding(dp(12),dp(5),dp(12),dp(5));root.addView(top);
        TextView mark=text("▣",25,accent,true);top.addView(mark);
        LinearLayout brand=column();top.addView(brand,new LinearLayout.LayoutParams(0,-2,1));
        brand.addView(text("DETECTIVE DESK",17,white,true));brand.addView(text("UNIDAD DE HOMICIDIOS  /  TERMINAL 04",9,muted,true));
        top.addView(text("● SISTEMA ACTIVO",10,accent,true));
        View line=new View(this);line.setBackgroundColor(accent);root.addView(line,new LinearLayout.LayoutParams(-1,dp(1)));
        LinearLayout row=new LinearLayout(this);root.addView(row,new LinearLayout.LayoutParams(-1,0,1));
        ScrollView menuScroll=new ScrollView(this);row.addView(menuScroll,new LinearLayout.LayoutParams(dp(155),-1));
        nav=column();nav.setPadding(dp(7),dp(9),dp(7),dp(9));menuScroll.addView(nav);
        String[] pages={"Inicio","Expediente","Interrogatorios","Laboratorio","Tablero","Cronología","Notas","Informe"};
        for(String p:pages){Button b=button(p);b.setTextSize(12);b.setOnClickListener(v->showPage(p));nav.addView(b,margin(0,0,0,5));}
        ScrollView scroll=new ScrollView(this);row.addView(scroll,new LinearLayout.LayoutParams(0,-1,1));
        content=column();content.setPadding(dp(10),dp(7),dp(14),dp(12));scroll.addView(content);
        footer=text("",10,accent,true);root.addView(footer);
        setContentView(root);
    }
    private LinearLayout.LayoutParams margin(int l,int t,int r,int b){LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(dp(l),dp(t),dp(r),dp(b));return p;}
    private Button button(String s){
        Button b=new Button(this);b.setText(s);b.setTextColor(white);b.setAllCaps(false);b.setTextSize(13);
        b.setBackground(shape(panel2,12));b.setPadding(dp(5),dp(3),dp(5),dp(3));return b;
    }
    private void card(String title,String body){
        LinearLayout box=column();box.setBackground(shape(panel,14));box.setPadding(dp(5),dp(4),dp(5),dp(5));
        box.addView(text(title,15,accent,true));
        TextView d=text(body,13,white,false);d.setPadding(dp(12),dp(3),dp(12),dp(12));box.addView(d);
        content.addView(box,margin(0,0,0,9));
    }
    private void action(String label,Runnable run){
        Button b=button(label);b.setOnClickListener(v->run.run());content.addView(b,margin(0,0,0,6));
    }
    private void persist(){
        getPreferences(0).edit().putStringSet("examined",new HashSet<>(examined))
            .putStringSet("unlocked",new HashSet<>(unlocked)).putStringSet("notes",new HashSet<>(notes)).apply();
    }
    private void showPage(String p){
        page=p;content.removeAllViews();
        TextView h=text(p.toUpperCase(Locale.ROOT),21,white,true);content.addView(h);
        switch(p){
            case "Inicio":
                card("EXPEDIENTE ACTIVO  /  RPD-026-114","MUERTE EN EL ALMACÉN 7\nVíctima: Daniel Ortega, 42 años\nEstado: Investigación abierta · Prioridad alta");
                card("CENTRO DE OPERACIONES","Pruebas examinadas: "+examined.size()+" / "+evidence.length+"\nEntrevistas iniciadas: "+unlocked.size()+" / 3\nNotas del investigador: "+notes.size());
                action("CONTINUAR INVESTIGACIÓN",()->showPage("Expediente"));
                action("ABRIR INTERROGATORIOS",()->showPage("Interrogatorios"));
                card("OBJETIVOS PENDIENTES","1. Examinar todas las pruebas.\n2. Contrastar las coartadas.\n3. Identificar contradicciones.\n4. Elaborar una conclusión respaldada por indicios.");
                break;
            case "Expediente":
                card("RPD-026-114  |  MUERTE EN EL ALMACÉN 7","Lugar: Distrito portuario, Almacén 7\nHallazgo: 23:40\nVíctima: Daniel Ortega\nInvestigador responsable: Inspector de guardia");
                card("RESUMEN DEL CASO","Daniel Ortega fue hallado sin vida en un almacén al que varias personas tenían acceso. La investigación debe determinar qué ocurrió, quién tuvo oportunidad y qué indicios pueden corroborarse.");
                card("PERSONAS DE INTERÉS",names[0]+" — "+roles[0]+"\n"+names[1]+" — "+roles[1]+"\n"+names[2]+" — "+roles[2]);
                card("PRUEBAS DEL EXPEDIENTE","Selecciona cada elemento para abrir su ficha, registrar su examen y consultar qué puede demostrar y qué no.");
                for(int i=0;i<evidence.length;i++){final int n=i;action((examined.contains(evidence[i])?"✓  ":"＋  ")+evidence[i],()->examine(n));}
                break;
            case "Laboratorio":
                card("LABORATORIO FORENSE","Informes técnicos disponibles. Los resultados distinguen hechos observados de hipótesis pendientes.");
                for(int i=0;i<evidence.length;i++){final int n=i;action(evidence[i]+(examined.contains(evidence[i])?"  · EXAMINADA":"  · PENDIENTE"),()->examine(n));}
                break;
            case "Interrogatorios":
                card("SALA DE ENTREVISTAS","Elige a una persona. Puedes escribir preguntas con tus propias palabras. El sistema mantiene el contexto del interrogatorio y utiliza las pruebas conocidas.");
                for(int i=0;i<3;i++){final int n=i;card(names[i]+"  ·  "+roles[i],profiles[i]+"\nPreguntas realizadas: "+questions.get(i));action("INICIAR / CONTINUAR ENTREVISTA",()->interview(n));}
                break;
            case "Tablero":
                card("TABLERO DE DEDUCCIONES","Pruebas examinadas: "+examined.size()+" / "+evidence.length);
                card("HECHOS CONFIRMADOS","• La víctima fue hallada a las 23:40.\n• El intervalo médico estimado es 23:10–23:35.\n• Una figura aparece a las 23:17.\n• Hubo una llamada a las 22:58.\n• Se registra una apertura a las 22:51.");
                card("HIPÓTESIS ABIERTAS","• La identidad de la figura no está confirmada.\n• La titularidad del número prepago no consta.\n• La credencial no demuestra quién la utilizó.\n• La huella parcial no identifica a una persona.");
                action("REVISAR PRUEBAS",()->showPage("Expediente"));
                break;
            case "Cronología":
                card("SECUENCIA TEMPORAL","Ordena los sucesos y compara sus horas con las declaraciones.");
                for(String t:timeline)card("REGISTRO",t);
                break;
            case "Notas":
                card("CUADERNO DEL INVESTIGADOR","Tus notas se guardan en el dispositivo.");
                EditText note=new EditText(this);note.setHint("Añade una observación, hipótesis o diligencia pendiente…");note.setTextColor(white);note.setHintTextColor(muted);note.setMinLines(2);note.setGravity(Gravity.TOP);note.setBackground(shape(panel2,10));content.addView(note,margin(0,0,0,7));
                action("GUARDAR NOTA",()->{String s=note.getText().toString().trim();if(!s.isEmpty()){notes.add(s);persist();showPage("Notas");}});
                for(String s:notes)card("ANOTACIÓN",s);
                break;
            case "Informe":
                card("INFORME PROVISIONAL DE INVESTIGACIÓN","Expediente RPD-026-114\nVíctima: Daniel Ortega\nPruebas examinadas: "+examined.size()+"/"+evidence.length+"\nPersonas entrevistadas: "+unlocked.size()+"/3");
                card("VALORACIÓN","Con la información actual no es posible atribuir de forma concluyente la autoría a una persona. Deben corroborarse las coartadas, la credencial de acceso y la identidad de la figura captada.");
                action("COPIAR INFORME",()->{String report="INFORME RPD-026-114\nMuerte en el Almacén 7\nPruebas examinadas: "+examined+"\nNotas: "+notes+"\nConclusión: investigación abierta; no existe identificación concluyente.";((android.content.ClipboardManager)getSystemService(CLIPBOARD_SERVICE)).setPrimaryClip(android.content.ClipData.newPlainText("Informe Detective Desk",report));Toast.makeText(this,"Informe copiado",Toast.LENGTH_SHORT).show();});
                break;
        }
        footer.setText("● "+examined.size()+"/"+evidence.length+" PRUEBAS  |  PROGRESO GUARDADO EN EL DISPOSITIVO");
    }
    private void examine(int i){
        examined.add(evidence[i]);persist();
        new android.app.AlertDialog.Builder(this).setTitle(evidence[i]).setMessage(details[i]+"\n\nVALOR PROBATORIO\n"+evidenceValue(i)+"\n\nLÍMITE DEL INDICIO\n"+evidenceLimit(i))
            .setPositiveButton("Añadir a mis notas",(d,w)->{notes.add("Prueba: "+evidence[i]+". "+details[i]);persist();showPage("Expediente");})
            .setNegativeButton("Cerrar",(d,w)->showPage("Expediente")).show();
    }
    private String evidenceValue(int i){
        String[] v={"Describe el estado inicial del lugar y orienta las diligencias de inspección.","Acredita que existió una comunicación, no quién utilizó el teléfono.","Sitúa una figura en una zona y momento determinados.","Aporta un intervalo aproximado para contrastar coartadas.","Acredita la recuperación de un rastro biológico parcial.","Registra el uso de una credencial en una hora concreta.","Apunta a un posible conflicto económico que requiere documentación completa.","Permite estudiar accesos y cobertura de vigilancia."};return v[i];
    }
    private String evidenceLimit(int i){
        String[] v={"No identifica por sí mismo al autor ni reconstruye toda la secuencia.","El número prepago no tiene titular identificado en el expediente.","La imagen no permite reconocer el rostro ni identificar la ropa de forma exclusiva.","No fija una hora exacta ni identifica a quien estuvo presente.","No existe identificación concluyente de la muestra.","No demuestra qué persona llevaba la tarjeta.","El borrador no demuestra por sí solo un móvil delictivo.","El plano no demuestra que alguien utilizara el punto ciego."};return v[i];
    }
    private void interview(int who){
        suspect=who;unlocked.add(names[who]);persist();
        content.removeAllViews();content.addView(text("ENTREVISTA / "+names[who].toUpperCase(Locale.ROOT),20,white,true));
        card("FICHA DEL ENTREVISTADO",profiles[who]);
        int level=pressure.get(who);
        card("ACTITUD Y CONTEXTO","Entrevista registrada: "+questions.get(who)+" preguntas.\nTensión de la entrevista: "+(level<2?"Baja":level<5?"Moderada":"Alta")+".\nHaz preguntas concretas y contrasta las respuestas con los indicios.");
        LinearLayout transcript=column();content.addView(transcript);
        for(String line:log)if(line.startsWith("S"+who+"|"))card(line.substring(line.indexOf("|")+1),line.substring(line.indexOf("§")+1));
        TextView qlabel=text("TU PREGUNTA",12,accent,true);content.addView(qlabel);
        questionInput=new EditText(this);questionInput.setSingleLine(false);questionInput.setMinLines(2);questionInput.setTextColor(white);questionInput.setHintTextColor(muted);
        questionInput.setHint("Escribe cualquier pregunta sobre el caso…");questionInput.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_FLAG_CAP_SENTENCES|InputType.TYPE_TEXT_FLAG_MULTI_LINE);
        questionInput.setBackground(shape(panel2,12));content.addView(questionInput,margin(0,0,0,7));
        action("ENVIAR PREGUNTA",()->askQuestion());
        card("PREGUNTAS SUGERIDAS","Puedes preguntar por horarios, coartada, relación con Daniel, llamadas, accesos, cámaras, pruebas o contradicciones.");
        action("¿Dónde estabas a las 23:17?",()->quickAsk("¿Dónde estabas a las 23:17?"));
        action("¿Qué relación tenías con Daniel?",()->quickAsk("¿Qué relación tenías con Daniel?"));
        action("¿Conocías la credencial de mantenimiento?",()->quickAsk("¿Conocías la credencial de mantenimiento?"));
        action("¿Qué sabes de la llamada de las 22:58?",()->quickAsk("¿Qué sabes de la llamada de las 22:58?"));
        action("Volver a personas de interés",()->showPage("Interrogatorios"));
    }
    private void quickAsk(String q){questionInput.setText(q);askQuestion();}
    private void askQuestion(){
        String q=questionInput.getText().toString().trim();
        if(q.isEmpty()){Toast.makeText(this,"Escribe una pregunta para continuar.",Toast.LENGTH_SHORT).show();return;}
        ((InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(questionInput.getWindowToken(),0);
        questions.put(suspect,questions.get(suspect)+1);pressure.put(suspect,pressure.get(suspect)+1);
        String answer=generateAnswer(q,suspect);
        log.add("S"+suspect+"|PREGUNTA: "+q+"§RESPUESTA: "+answer);
        if(log.size()>90)log.remove(0);
        questionInput.setText("");
        interview(suspect);
        card("RESPUESTA DEL ENTREVISTADO",answer);
    }
    private String generateAnswer(String raw,int who){
        String q=raw.toLowerCase(Locale.ROOT);
        String whoName=names[who];
        boolean hasTime=q.matches(".*(hora|cuando|cuándo|23:|22:|noche|tarde|minuto|intervalo).*");
        boolean hasPlace=q.matches(".*(dónde|donde|lugar|sitio|ubicación|ubicacion|almacén|almacen|muelle).*");
        boolean hasVictim=q.matches(".*(daniel|víctima|victima|muerto|relación|relacion|conocías|conocias).*");
        boolean hasAccess=q.matches(".*(llave|tarjeta|credencial|acceso|puerta|entrar|entré|entre).*");
        boolean hasCamera=q.matches(".*(cámara|camara|vídeo|video|grabación|grabacion|figura|imagen).*");
        boolean hasCall=q.matches(".*(llamada|teléfono|telefono|número|numero|prepago).*");
        boolean hasEvidence=q.matches(".*(prueba|huella|forense|informe|sangre|muestra|evidencia).*");
        boolean hasMotive=q.matches(".*(motivo|móvil|movil|dinero|cuentas|deuda|beneficio|conflicto).*");
        boolean hasAlibi=q.matches(".*(coartada|demostrar|testigo|verificar|confirmar).*");
        String answer;
        if(hasTime){
            answer=who==0?"A esa hora estaba terminando las tareas del muelle. No puedo darte una hora exacta de memoria. Comprueba los turnos y los registros; si existe un registro que me sitúe allí, debería poder contrastarse.":who==1?"No voy a inventar una hora exacta. Mi agenda de esa noche y los movimientos que consten en los registros pueden comprobarse. No recuerdo haber estado dentro del Almacén 7.":"Estaba de servicio durante el turno nocturno. Mi presencia en la zona de seguridad es compatible con mis funciones, pero el registro horario debe comprobarlo. No puedo certificar cada minuto sin consultar el parte.";
            if(q.contains("23:17")||q.contains("figura"))answer+=" La cámara muestra una figura, pero con esa imagen no puedo afirmar quién es.";
        }else if(hasPlace){
            answer=who==0?"Mi puesto habitual era el muelle y la zona de carga. Tenía acceso laboral a distintas áreas, pero eso no significa que entrara en el almacén esa noche.":who==1?"Mi actividad se desarrollaba principalmente fuera del almacén. Podía acudir por motivos comerciales, pero no recuerdo haber entrado esa noche.":"Mi puesto estaba en seguridad. Recorría las zonas asignadas y podía pasar por el muelle; el parte de rondas debería precisar el recorrido.";
        }else if(hasVictim){
            answer=who==0?"Daniel coordinaba operaciones del almacén. Nuestra relación era profesional; discutimos por cambios de horario, pero no voy a convertir una discusión laboral en una confesión de algo que no hice.":who==1?"Daniel y yo manteníamos una relación comercial. Había desacuerdos sobre unas cuentas pendientes y quería revisarlas, pero un conflicto económico no demuestra que yo le hiciera daño.":"Trataba con Daniel por cuestiones de seguridad y funcionamiento del almacén. No éramos amigos íntimos; mi relación con él era principalmente laboral.";
        }else if(hasAccess){
            answer=who==0?"Conocía los accesos de trabajo y los procedimientos del muelle. La credencial de mantenimiento no demuestra quién la utilizó físicamente; habría que revisar quién podía disponer de ella.":who==1?"No era responsable de las tarjetas de acceso. Si mi nombre aparece en algún registro, debe comprobarse qué credencial se usó y quién tenía su custodia.":"Conocía el sistema de seguridad y las zonas de cobertura. La apertura registrada a las 22:51 debe contrastarse con el control de entrega de credenciales y el parte de servicio.";
        }else if(hasCamera){
            answer=who==0?"No puedo identificar a la persona de la grabación. Una chaqueta clara no es una identificación y no sería serio afirmar que soy yo o que es otra persona.":who==1?"No reconozco a nadie con seguridad en esa imagen. La grabación no muestra el rostro y no permite atribuir la presencia a una persona concreta.":"Conozco la ubicación de las cámaras por mi trabajo. La grabación tiene un punto ciego, pero eso no demuestra que alguien lo utilizara para cometer un delito.";
        }else if(hasCall){
            answer=who==0?"No reconozco ese número prepago. Para saber quién realizó la llamada hacen falta datos de la operadora y otras comprobaciones; la hora por sí sola no me vincula.":who==1?"No puedo identificar el titular del número con la información que me muestras. Revisaría los registros telefónicos y la duración de la llamada antes de sacar conclusiones.":"No tengo constancia de ser el destinatario de esa llamada. El registro acredita una comunicación, pero no revela por sí solo quién estaba detrás del número.";
        }else if(hasEvidence){
            answer="He entendido que preguntas por las pruebas. El expediente describe: "+knownEvidenceSummary()+". Ninguna de esas piezas, considerada aisladamente, permite identificarme. Si tienes una prueba concreta, dime cuál y responderé sobre ella.";
        }else if(hasMotive){
            answer=who==0?"No tenía un motivo para matar a Daniel. Sí hubo desacuerdos por la organización del trabajo, pero no equivalen a una intención homicida.":who==1?"Existían diferencias económicas y quería revisar las cuentas. No voy a negar el conflicto, pero no acepto que se convierta automáticamente en un móvil para un homicidio.":"No tenía intereses económicos con Daniel. Mi responsabilidad era la seguridad del recinto, no sus negocios.";
        }else if(hasAlibi){
            answer=who==0?"Mi coartada debe comprobarse con el cuadrante de turnos, los registros de actividad del muelle y cualquier testigo que estuviera trabajando. No te pediré que aceptes mi palabra sin verificarla.":who==1?"Puedes comprobar mi agenda, comunicaciones y los movimientos que estén documentados. No tengo aquí un justificante que cubra cada minuto, así que no voy a inventarlo.":"El parte de servicio y las rondas de vigilancia son la vía para comprobar mi recorrido. Solicita el registro completo y contrástalo con las cámaras.";
        }else{
            answer=answerOpenQuestion(q,who);
        }
        if(pressure.get(who)>=5)answer+="\n\n(El entrevistado muestra signos de tensión y pide que la pregunta se concrete.)";
        return answer;
    }
    private String knownEvidenceSummary(){
        ArrayList<String> list=new ArrayList<>();for(String e:evidence)if(examined.contains(e))list.add(e);
        return list.isEmpty()?"Aún no has examinado ninguna prueba.":String.join(", ",list);
    }
    private String answerOpenQuestion(String q,int who){
        String[] words=q.replaceAll("[^\\p{L}\\p{N} ]"," ").split("\\s+");
        StringBuilder topic=new StringBuilder();for(String w:words)if(w.length()>4&&!Arrays.asList("puedes","podrías","quieres","sobre","entonces","explica","dime","usted","tienes","tiene","hacer","decir").contains(w)){if(topic.length()>0)topic.append(", ");topic.append(w);}
        String focus=topic.length()==0?"lo que acabas de preguntar":topic.toString();
        String personal=who==0?"No tengo información directa que confirme ese extremo desde mi puesto en el muelle.":who==1?"No puedo confirmar ese detalle con la documentación que conozco.": "No consta ese detalle en el parte de seguridad que he consultado.";
        return "Sobre "+focus+": "+personal+"\n\nLo que sí puedo decirte es que debes contrastarlo con los registros del expediente. No voy a inventar un dato que no conozco ni a atribuir a otra persona algo que no he visto. Si preguntas por un hecho concreto, puedo responder sobre él.";
    }
    @Override public void onBackPressed(){if(!page.equals("Inicio"))showPage("Inicio");else super.onBackPressed();}
}
