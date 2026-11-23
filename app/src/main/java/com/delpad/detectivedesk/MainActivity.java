package com.delpad.detectivedesk;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.widget.*;
import android.text.InputType;
import java.util.*;

public class MainActivity extends Activity {
    private final int bg = Color.rgb(11,20,32), panel = Color.rgb(20,34,51), accent = Color.rgb(66,198,181), white = Color.rgb(237,244,248), muted = Color.rgb(154,175,194);
    private LinearLayout content, nav;
    private TextView heading, footer;
    private String page = "Inicio";
    private int selected = 0;
    private final Set<String> examined = new HashSet<>();
    private final ArrayList<String> notes = new ArrayList<>();
    private final String[] names = {"Álvaro Méndez","Lucía Ferrer","Iván Robles"};
    private final String[] roles = {"Encargado del muelle","Socia comercial","Guardia de seguridad"};
    private final String[] evidence = {"Informe de escena","Registro de llamadas","Cámara del muelle","Informe médico","Huella parcial"};
    private final String[] details = {
        "Daniel Ortega fue encontrado en el Almacén 7 a las 23:40. No se aprecian signos claros de entrada forzada.",
        "Llamada entrante de cuatro minutos a las 22:58 desde un número prepago.",
        "Una figura con chaqueta clara aparece cerca del almacén a las 23:17. La imagen no permite reconocer el rostro.",
        "Intervalo estimado de muerte: entre las 23:10 y las 23:35.",
        "Fragmento recuperado del pomo interior. La muestra no permite una identificación concluyente."
    };

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setStatusBarColor(bg);
        getWindow().setNavigationBarColor(bg);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        getPreferences(0).getStringSet("examined", new HashSet<>()).forEach(examined::add);
        buildShell();
        showPage("Inicio");
    }

    private GradientDrawable shape(int color) {
        GradientDrawable d = new GradientDrawable(); d.setColor(color); d.setCornerRadius(18); return d;
    }
    private TextView text(String value, int size, int color, boolean bold) {
        TextView t = new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(color);
        if (bold) t.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        t.setPadding(16,12,16,12); return t;
    }
    private LinearLayout column() {
        LinearLayout l = new LinearLayout(this); l.setOrientation(LinearLayout.VERTICAL); return l;
    }
    private void buildShell() {
        LinearLayout root = column(); root.setBackgroundColor(bg);
        TextView brand = text("▣  UNIDAD DE HOMICIDIOS  /  SISTEMA INTERNO",16,accent,true);
        root.addView(brand);
        View line = new View(this); line.setBackgroundColor(accent); root.addView(line,new LinearLayout.LayoutParams(-1,2));
        LinearLayout row = new LinearLayout(this); row.setOrientation(LinearLayout.HORIZONTAL); root.addView(row,new LinearLayout.LayoutParams(-1,0,1));
        ScrollView menuScroll = new ScrollView(this); menuScroll.setBackgroundColor(bg);
        row.addView(menuScroll,new LinearLayout.LayoutParams(dp(190),-1));
        nav = column(); nav.setPadding(8,8,8,8); menuScroll.addView(nav);
        String[] pages = {"Inicio","Expedientes","Interrogatorios","Laboratorio","Tablero","Notas"};
        for(String p:pages) { Button b=button(p); b.setOnClickListener(v->showPage(p)); nav.addView(b); }
        ScrollView scroll = new ScrollView(this); row.addView(scroll,new LinearLayout.LayoutParams(0,-1,1));
        content = column(); content.setPadding(10,8,18,12); scroll.addView(content);
        heading = text("",25,white,true); content.addView(heading);
        footer = text("● PROGRESO LOCAL  |  EXPEDIENTE RPD-026-114",11,accent,true); root.addView(footer);
        setContentView(root);
    }
    private int dp(int n){return (int)(n*getResources().getDisplayMetrics().density+0.5f);}
    private Button button(String label) {
        Button b=new Button(this); b.setText(label); b.setTextColor(white); b.setAllCaps(false); b.setTextSize(14);
        b.setBackground(shape(panel)); b.setPadding(8,4,8,4); return b;
    }
    private void card(String title,String detail) {
        LinearLayout box=column(); box.setBackground(shape(panel)); box.setPadding(8,8,8,8);
        TextView h=text(title,17,accent,true); box.addView(h);
        TextView d=text(detail,14,white,false); d.setPadding(16,4,16,14); box.addView(d);
        LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(-1,-2); lp.setMargins(0,0,0,dp(10)); content.addView(box,lp);
    }
    private void action(String label,Runnable run) {
        Button b=button(label); b.setOnClickListener(v->run.run());
        LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(-1,-2); lp.setMargins(0,0,0,dp(7)); content.addView(b,lp);
    }
    private void showPage(String p) {
        page=p; content.removeAllViews(); heading.setText(p.toUpperCase(Locale.ROOT));
        switch(p) {
            case "Inicio":
                card("BUENAS NOCHES, INSPECTOR","Terminal de investigación de la Unidad de Homicidios. Examina las pruebas, entrevista a las personas de interés y documenta tus deducciones.");
                card("CASO ACTIVO  •  RPD-026-114","Muerte en el Almacén 7\nVíctima: Daniel Ortega, 42 años\nEstado: Investigación abierta");
                card("RESUMEN","Pruebas examinadas: "+examined.size()+"/"+evidence.length+"\nNotas registradas: "+notes.size());
                action("Abrir expediente",()->showPage("Expedientes"));
                action("Interrogar sospechosos",()->showPage("Interrogatorios"));
                break;
            case "Expedientes":
                card("RPD-026-114  |  MUERTE EN EL ALMACÉN 7","Aviso: 23:40\nLugar: Distrito portuario, Almacén 7\nVíctima: Daniel Ortega");
                card("INSTRUCCIONES","Abre cada prueba para examinarla. Una sospecha no equivale a una conclusión probada.");
                for(int i=0;i<evidence.length;i++){ final int n=i; action((examined.contains(evidence[i])?"✓  ":"＋  ")+evidence[i],()->examine(n)); }
                break;
            case "Laboratorio":
                card("LABORATORIO FORENSE","Solicitudes y análisis disponibles del expediente.");
                for(int i=0;i<evidence.length;i++) card(evidence[i],details[i]);
                break;
            case "Interrogatorios":
                card("PERSONAS DE INTERÉS","Selecciona a quién deseas entrevistar. Las respuestas son locales y no requieren conexión.");
                for(int i=0;i<names.length;i++){ final int n=i; action(names[i]+"  ·  "+roles[i],()->interview(n));}
                break;
            case "Tablero":
                card("TABLERO DE DEDUCCIONES","Pruebas examinadas: "+examined.size()+"/"+evidence.length);
                card("CRONOLOGÍA PROVISIONAL","22:58 — llamada prepago\n23:10–23:35 — intervalo médico\n23:17 — figura captada por cámara\n23:40 — aviso a emergencias");
                card("ADVERTENCIA","Los indicios disponibles no permiten identificar de forma concluyente a una persona responsable.");
                break;
            case "Notas":
                card("CUADERNO DEL INVESTIGADOR","Registra observaciones propias del caso.");
                EditText input=new EditText(this); input.setHint("Escribe una nota de investigación…"); input.setTextColor(white); input.setHintTextColor(muted); input.setMinLines(2); input.setGravity(Gravity.TOP); content.addView(input);
                action("Guardar nota",()->{String s=input.getText().toString().trim(); if(!s.isEmpty()){notes.add(s);getPreferences(0).edit().putStringSet("examined",examined).putStringSet("notes",new HashSet<>(notes)).apply();showPage("Notas");}});
                for(String s:notes) card("NOTA",s);
                break;
        }
        footer.setText("● "+examined.size()+" PRUEBAS EXAMINADAS  |  GUARDADO LOCAL");
    }
    private void examine(int i) {
        examined.add(evidence[i]); getPreferences(0).edit().putStringSet("examined",examined).apply();
        new android.app.AlertDialog.Builder(this).setTitle(evidence[i]).setMessage(details[i]+"\n\nANÁLISIS PRELIMINAR\nEste indicio debe contrastarse con el resto de las pruebas. Por sí solo no identifica al responsable.").setPositiveButton("Volver", (d,w)->showPage("Expedientes")).show();
    }
    private void interview(int i) {
        selected=i;
        String[] prompts={"¿Dónde estabas entre las 23:10 y las 23:35?","¿Qué relación tenías con Daniel Ortega?","¿Conocías el sistema de acceso del almacén?","¿Puedes aportar alguna prueba de tu coartada?"};
        final String[] answer={""};
        EditText input=new EditText(this); input.setTextColor(white); input.setHintTextColor(muted); input.setHint("Escribe tu pregunta…");
        new android.app.AlertDialog.Builder(this).setTitle("Entrevista: "+names[i]).setMessage("Perfil: "+roles[i]+".\n"+(i==0?"Conocía los horarios de carga y tenía acceso habitual.":i==1?"Mantenía negocios con la víctima.":"Conocía los puntos ciegos de vigilancia."))
        .setView(input).setPositiveButton("Preguntar",(d,w)->{
            String q=input.getText().toString().toLowerCase(Locale.ROOT);
            String a;
            if(q.contains("23")||q.contains("hora")||q.contains("dónde")||q.contains("donde")) a="Mantengo mi versión. Ya he explicado dónde estaba, pero no tengo documentación adicional en este momento.";
            else if(q.contains("daniel")||q.contains("relación")||q.contains("relacion")) a="Nuestra relación era estrictamente profesional. Tuvimos desacuerdos, pero eso no demuestra que yo tenga relación con su muerte.";
            else if(q.contains("cámara")||q.contains("camara")||q.contains("acceso")) a="Conozco algunos procedimientos del almacén, como otras personas que trabajaban allí. No puedo identificar a la figura de la grabación.";
            else a="No puedo aportar más detalles sin conocer exactamente a qué se refiere. Formule una pregunta concreta.";
            new android.app.AlertDialog.Builder(this).setTitle(names[i]).setMessage("PREGUNTA: "+input.getText()+"\n\nRESPUESTA:\n"+a).setPositiveButton("Continuar",(x,y)->showPage("Interrogatorios")).show();
        }).setNegativeButton("Cerrar",(d,w)->showPage("Interrogatorios")).show();
    }
}
