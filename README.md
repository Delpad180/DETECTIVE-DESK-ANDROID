# Detective Desk — Android

Juego de investigación policial original inspirado en simuladores de escritorio policial. Proyecto Godot 4, interfaz moderna y español.

## Estado
**Prototipo 0.1 — estructura inicial**

- Escritorio de comisaría y navegación por módulos.
- Caso inicial RPD-026-114.
- Expediente, evidencias y sospechosos.
- Interrogatorios offline basados en hechos del caso (motor narrativo inicial).
- Laboratorio, tablero, correo, patrullas y Asuntos Internos en versión inicial.

## Requisitos
- Godot 4.3 o posterior.
- Renderizador Compatibility (OpenGL ES 3).
- Resolución base 1280×720, adaptable a pantallas Android.

## Abrir el proyecto
Importar `project.godot` desde Godot.

## Hoja de ruta
1. Interfaz táctil y persistencia local.
2. Casos ramificados, evidencias y cronología.
3. Motor de interrogatorio local con memoria de hechos, contradicciones y estados emocionales.
4. Laboratorio interactivo y tablero de deducciones.
5. Campaña, economía, rangos, juicios y consecuencias.
6. Exportación APK y pruebas en dispositivos reales.

## IA sin conexión
La primera versión usa diálogo determinista local. No requiere Internet. La integración de un modelo lingüístico local cuantizado será una fase separada, porque requiere elegir un modelo compatible con la memoria y potencia del dispositivo. No se enviarán conversaciones a servidores externos.

## Nota
Proyecto independiente con personajes, casos, textos y recursos originales; no utiliza código ni activos propietarios de otros juegos.
