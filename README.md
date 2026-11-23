# Detective Desk — Android nativo

Detective Desk es una aplicación de investigación policial original para Android. La nueva versión se está migrando a **Android nativo con Java y Gradle**. No utiliza Godot ni necesita instalar un motor de juegos.

## Compilación

GitHub Actions compila la APK de depuración automáticamente. En el repositorio, abre la pestaña **Actions**, selecciona **Compilar APK Android nativa** y descarga el artefacto `Detective-Desk-Android-Nativo` cuando el flujo termine correctamente.

## Funciones incluidas en la primera base nativa

- Interfaz policial oscura en orientación horizontal.
- Expediente RPD-026-114: muerte en el Almacén 7.
- Cinco pruebas examinables con análisis preliminar.
- Tres personas de interés.
- Interrogatorios locales con respuestas según el tema de la pregunta.
- Tablero con cronología provisional y advertencia sobre límites de los indicios.
- Cuaderno de notas.
- Persistencia local de pruebas examinadas y notas.

## Estado

Esta es la **primera base nativa**, no una conversión completa de todas las funciones del prototipo anterior. Se conservará el diseño y se irán incorporando las funciones del expediente por fases. La compilación correcta no sustituye las pruebas en un teléfono Android real.

## Tecnología

- Java para Android.
- Android Gradle Plugin 8.6.1.
- Gradle 8.7.
- SDK Android 35.
- Min SDK 23.
- La lógica de investigación inicial funciona sin conexión.
