## PrecioLed Frontend

### Compilar y ejecutar:

#### Developer Tools

`make run`

#### Generar Windows DLLs

`make windows`

#### Ejecutar Demo .NET

Abrir el proyecto .NET que se encuentra dentro de `demo/DemoNET` y compilarlo con Visual Studio.

#### Generación Assets

##### Videos con transparencia

Para maximizar la velocidad de carga de video, utilizamos raw video, lo cual nos permite evitar el uso de un decoder específico.
Ejemplo de encoding raw con transparencias (ADVERTENCIA: genera archivos muy pesados):

`ffmpeg -i _assets/countdown.mov -c:v rawvideo -pix_fmt rgba assets/countdown_raw.avi`

Formatos soportados por FFMPEG:

`ffmpeg -pix_fmts`

Hay varios otros containers y codecs que soportan transparencia, pero en general tienen algunos de los siguientes inconvenientes:
 - Utilizan formato `yuva` en lugar de `rgba`, lo cual requiere un paso extra de conversión, afectando negativamente la performance.
 - Algunos no tienen aceleración por hardware. Por ejemplo, el codec `ffV1` genera archivos pequeños y soporta `rgba`, pero no tiene aceleración por hardware, lo cual lo hace entre 10 y 100 veces más lento que otros a la hora de decodificar.

##### Videos sin transparencia

Containers `.mkv`, `.avi`, `.mov`, `webm` y `.mp4` son soportados.
En particular, para videos sin pérdida de calidad y con un alto nivel de compresión, se recomienda utilizar `webm` con codec `v9`.
Pero en general la gran mayoría de formatos y codecs son soportados. Aquí la recomendación es siempre optar por codecs que tengan aceleración por hardware.


