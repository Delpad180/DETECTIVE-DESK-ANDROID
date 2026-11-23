package com.delpad.detectivedesk;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import java.util.Set;

/** Tablero táctil de evidencias con conexiones persistentes controladas por MainActivity. */
public class EvidenceBoardView extends View {
    public interface OnConnectionsChanged { void changed(); }
    private final String[] labels;
    private final Set<String> examined;
    private final Set<String> connections;
    private final OnConnectionsChanged listener;
    private final Paint paint = new Paint(3);
    private final RectF[] cards;
    private int threadColor;
    private int selected = -1;
    private final int background = Color.rgb(10,18,29), cardColor = Color.rgb(29,45,63);
    private final int white = Color.rgb(237,244,250), muted = Color.rgb(151,174,194);
    public EvidenceBoardView(Context context, String[] labels, Set<String> examined, Set<String> connections, int color, OnConnectionsChanged listener) {
        super(context); this.labels=labels; this.examined=examined; this.connections=connections; this.threadColor=color; this.listener=listener;
        this.cards=new RectF[labels.length]; setLayerType(View.LAYER_TYPE_SOFTWARE,null);
    }
    public void setThreadColor(int color) { threadColor=color; invalidate(); }
    private float dp(float n) { return n*getResources().getDisplayMetrics().density; }
    private void layoutCards() {
        float pad=dp(12), gap=dp(12), w=(getWidth()-2*pad-gap)/2f, h=dp(82);
        for(int i=0;i<labels.length;i++){int col=i%2,row=i/2;float x=pad+col*(w+gap),y=pad+row*(h+dp(22));cards[i]=new RectF(x,y,x+w,y+h);}
    }
    private int parseColor(String s) { try{return (int)Long.parseLong(s,16);}catch(Exception e){return Color.WHITE;} }
    @Override protected void onDraw(Canvas canvas) {
        super.onDraw(canvas); canvas.drawColor(background); layoutCards();
        paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(dp(3)); paint.setStrokeCap(Paint.Cap.ROUND);
        for(String link:connections){String[] p=link.split(":");if(p.length!=3)continue;try{
            int a=Integer.parseInt(p[0]),b=Integer.parseInt(p[1]);if(a<0||b<0||a>=cards.length||b>=cards.length)continue;
            RectF ra=cards[a],rb=cards[b];float x1=ra.centerX(),y1=ra.centerY(),x2=rb.centerX(),y2=rb.centerY();
            Path path=new Path();path.moveTo(x1,y1);float bend=Math.max(dp(30),Math.abs(x2-x1)*.18f);path.cubicTo(x1+bend,y1,x2-bend,y2,x2,y2);
            paint.setColor(parseColor(p[2]));paint.setAlpha(225);canvas.drawPath(path,paint);
        }catch(Exception ignored){}}
        for(int i=0;i<cards.length;i++){RectF r=cards[i];paint.setStyle(Paint.Style.FILL);paint.setColor(cardColor);canvas.drawRoundRect(r,dp(10),dp(10),paint);
            paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(dp(2));paint.setColor(i==selected?Color.WHITE:(examined.contains(labels[i])?Color.rgb(55,210,185):Color.rgb(74,94,116)));canvas.drawRoundRect(r,dp(10),dp(10),paint);
            paint.setStyle(Paint.Style.FILL);paint.setColor(white);paint.setTextSize(dp(12));paint.setFakeBoldText(true);String label=labels[i];
            while(paint.measureText(label)>r.width()-dp(18)&&label.length()>5)label=label.substring(0,label.length()-2)+"…";
            canvas.drawText(label,r.left+dp(9),r.centerY()+dp(4),paint);paint.setFakeBoldText(false);paint.setTextSize(dp(9));
            paint.setColor(examined.contains(labels[i])?Color.rgb(55,210,185):muted);canvas.drawText(examined.contains(labels[i])?"EXAMINADA":"PENDIENTE",r.left+dp(9),r.bottom-dp(8),paint);
        }
        paint.setStyle(Paint.Style.FILL);paint.setColor(muted);paint.setTextSize(dp(10));canvas.drawText(selected<0?"ELIGE LA PRIMERA PISTA":"AHORA ELIGE LA SEGUNDA PISTA",dp(12),getHeight()-dp(8),paint);
    }
    @Override public boolean onTouchEvent(MotionEvent event) {
        if(event.getAction()!=MotionEvent.ACTION_UP)return true;
        if(cards[0]==null)layoutCards();
        for(int i=0;i<cards.length;i++)if(cards[i]!=null&&cards[i].contains(event.getX(),event.getY())){
            if(selected<0)selected=i;else if(selected==i)selected=-1;else{
                int a=Math.min(selected,i),b=Math.max(selected,i);String link=a+":"+b+":"+Integer.toHexString(threadColor);
                boolean removed=false;for(String old:new java.util.HashSet<String>(connections)){String[] p=old.split(":");if(p.length>=2&&p[0].equals(String.valueOf(a))&&p[1].equals(String.valueOf(b))){connections.remove(old);removed=true;break;}}
                if(!removed)connections.add(link);selected=-1;if(listener!=null)listener.changed();
            }invalidate();performClick();return true;
        }return true;
    }
    @Override public boolean performClick(){super.performClick();return true;}
}
