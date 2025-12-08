CREAR BARRA DE PROGRESO:
function Start-ProgressBar { #Se define una función llamada Start-ProgressBar, dentro está toda la lógica para crear una barra de progreso animada.
    [CmdletBinding()] #Hace que la función se comporte como un cmdlet profesional, para más control de parámetros y comportamiento.
    param ( #Define los parámetros que la función requiere.
        [Parameter(Mandatory = $true)] #Primer parámetro obligatorio: Title, es el título que aparecerá en la barra de progreso.
        $Title,
        
        [Parameter(Mandatory = $true)] #Segundo parámetro obligatorio: Timerm, debe ser un número entero, este representa cuántos segundos dura la barra de progreso.
        [int]$Timer
    )
    
    for ($i = 1; $i -le $Timer; $i++) { #Un bucle que va desde 1 hasta el número que indique el Timer, cada vuelta del bucle representa 1 segundo transcurrido.
        Start-Sleep -Seconds 1 #Pausa el programa durante 1 segundo, esto hace que la barra avance tiempo real.
        $percentComplete = ($i / $Timer) * 100 #Calcula el porcentaje completado.
        Write-Progress -Activity $Title -Status "$i seconds elapsed" -PercentComplete $percentComplete #Muestra la barra de progreso en pantalla con: 1)Activity, título de la barra. 2)Status, mensaje mostrando cuántos segundos han pasado. 3)PercentComplete, porcentaje que se calcula cada vuelta
    }
} 

Start-ProgressBar -Title "Test timeout" -Timer 30 #Ejecuta la barra de progreso