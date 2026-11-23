# Servidor de IA de Detective Desk

La aplicación Android ya incluye el cliente HTTPS. Este servidor mantiene la clave de OpenAI fuera de la APK y permite respuestas generales, contexto del expediente y búsqueda web.

## Despliegue con Render

1. Crea una cuenta en Render y conecta el repositorio GitHub `Delpad180/DETECTIVE-DESK-ANDROID`.
2. En Render, selecciona **New + → Blueprint** y elige este repositorio. Render detectará `render.yaml`.
3. Cuando solicite `OPENAI_API_KEY`, introduce una clave de proyecto de OpenAI API. No la publiques en GitHub ni la escribas en la aplicación.
4. Confirma el despliegue y espera a que el servicio esté activo.
5. Copia la URL HTTPS pública del servicio, por ejemplo `https://detective-desk-ai.onrender.com`.
6. En Detective Desk abre **IA en línea**, pega esa URL, pulsa **Guardar dirección del servidor** y después **Probar conexión**.

## Credenciales y costes

- La API de OpenAI se factura por uso y es independiente de ChatGPT Plus/Free.
- Crea una clave en el panel de OpenAI Platform y añade un límite de gasto al proyecto.
- La clave solo debe guardarse como variable de entorno `OPENAI_API_KEY` en Render.
- El servidor aplica un límite básico de 15 solicitudes por minuto por IP. Configura también límites de gasto en el proveedor.
- El plan gratuito de alojamiento puede suspender el servicio por inactividad y tardar en despertar.

## Endpoints

- `GET /health`: estado del servicio.
- `POST /api/chat`: pregunta, contexto del expediente e historial reciente.
- Modelo por defecto: `gpt-6.2-sol`.
- Búsqueda web habilitada para consultas que necesiten información actual.

No se incluye una clave de API en el repositorio ni en la APK.
