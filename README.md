# Detective Desk — Android

Juego de investigación policial original para Android, desarrollado con Godot 4 y con interfaz en español.

## Estado actual

**Prototipo 0.2 — primera fase jugable de investigación**

Implementado en el proyecto:

- Escritorio de comisaría y navegación por módulos.
- Caso original RPD-026-114: muerte en el Almacén 7.
- Cinco pruebas examinables con ficha, categoría y análisis preliminar.
- Tres personas de interés con perfiles, motivos y coartadas.
- Interrogatorios locales con respuestas deterministas, historial individual y nivel de tensión por entrevistado.
- Presentación de pruebas examinadas durante las entrevistas.
- Tablero con deducciones que se desbloquean al examinar las pruebas relacionadas.
- Cronología provisional y solicitudes de análisis complementario.
- Notas de investigación y registro de acciones.
- Guardado y carga local del progreso mediante user://detective_desk_save.cfg.
- Cierre administrativo condicionado a revisar las pruebas y registrar deducciones. El juego no declara culpable a ningún sospechoso con los indicios actuales.

## Validación automática

El repositorio incluye un flujo de GitHub Actions que instala Godot 4.3, importa el proyecto y realiza una prueba de arranque sin interfaz gráfica en cada push y pull request. La existencia del flujo no significa que la compilación haya pasado: el resultado debe consultarse en la pestaña Actions.

## Requisitos

- Godot 4.3 o posterior.
- Renderizador Compatibility.
- Resolución base 1280×720; interfaz desplazable y controles grandes pensados para pantallas táctiles.
- Orientación horizontal en Android.

## Abrir el proyecto

Importa project.godot desde Godot 4.3 o posterior y ejecuta la escena principal.

## Próximas fases

1. Probar y corregir el proyecto en Godot y en dispositivos Android reales.
2. Ampliar la investigación con nuevas localizaciones, testigos y pruebas.
3. Añadir relaciones verificables entre sospechosos, objetos, ubicaciones y cronología.
4. Crear un sistema de interrogatorios con estados conversacionales más profundos.
5. Incorporar un modelo lingüístico local cuantizado, si el rendimiento y el tamaño de la aplicación lo permiten.
6. Completar campaña, economía, rangos, juicios y consecuencias.
7. Configurar exportación automatizada del APK y firma de distribución.

## Interrogatorios sin conexión

La versión actual utiliza lógica determinista local: selecciona respuestas según el contenido de la pregunta, la prueba presentada y el estado de tensión. **Todavía no contiene un modelo de lenguaje ni una IA generativa.** No requiere Internet y no envía conversaciones a servidores externos.

La integración futura de un modelo lingüístico local será una fase separada y dependerá de la memoria y potencia de los dispositivos compatibles.

## Guardado

El progreso se guarda en el almacenamiento privado de la aplicación mediante el sistema ConfigFile de Godot. Desinstalar la aplicación o borrar sus datos puede eliminar la partida.

## Nota

Proyecto independiente con personajes, casos, textos y recursos originales. No utiliza código ni activos propietarios de otros juegos.
