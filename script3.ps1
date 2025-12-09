#Función para crear carpetas
function New-FolderCreation { #Define la función New-FolderCreation
    [CmdletBinding()] #Habilita características avanzadas de PowerShell para la función.
    param( #Define los parámetros de la función.
        [Parameter(Mandatory = $true)] #Indica que foldername es obligatorio.
        [string]$foldername #Define que foldername es un texto
    )

    #Obtiene la ruta actual y le agrega el nombre de la carpeta que queremos crear.
    $logpath = Join-Path -Path (Get-Location).Path -ChildPath $foldername
    if (-not (Test-Path -Path $logpath)) {
        New-Item -Path $logpath -ItemType Directory -Force | Out-Null
    }
#Comprueba si la carpeta existe o no y si no existe, la crea.
    return $logpath #Devuelve la ruta completa de la carpeta.
}
#Define la función Write-Log, que sirve para crear archivos de log o escribir mensajes.
#Soporta dos conjuntos de parámetros: Create (crear archivo de log) y Message (escribir mensaje).
function Write-Log {
    [CmdletBinding()]
    param(
        #Este bloque define los parámetros necesarios para crear archivos de log.
        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [Alias('Names')]
        [object]$Name,  # $Name es un parámetro obligatorio cuando se quiere crear un archivo.

        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [string]$Ext, #La extensión del archivo.

        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [string]$folder, #Carpeta donde se guardarán los archivos.

        [Parameter(ParameterSetName = 'Create', Position = 0)]
        [switch]$Create, #Switch que activa el modo “crear archivo”.

        #Parámetros necesarios para escribir mensajes dentro de un archivo.
        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [string]$message,
        #Texto que se escribirá dentro del archivo de log.
        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [string]$path,
        #Ruta del archivo donde se escribirá el mensaje.
        [Parameter(Mandatory = $false, ParameterSetName = 'Message')]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information',
        #Nivel de importancia del mensaje (info, advertencia o error).
        [Parameter(ParameterSetName = 'Message', Position = 0)]
        [switch]$MSG
    ) #Interruptor que indica que esta acción es para escribir un mensaje en el log.

    switch ($PsCmdlet.ParameterSetName) {  #Elige si se está llamando a la función en modo “Create” o “Message”.
        "Create" {
            $created = @() #Si el modo es “Create”, comienza un arreglo para almacenar las rutas de los archivos creados.

            #Convierte un nombre suelto o varios nombres en un arreglo uniforme para poder procesarlos uno por uno.
            $namesArray = @()
            if ($null -ne $Name) {
                if ($Name -is [System.Array]) { $namesArray = $Name }
                else { $namesArray = @($Name) }
            }

            #Se crea un formato de fecha y hora que no da problemas en los nombres de archivo.
            $date1 = (Get-Date -Format "yyyy-MM-dd")
            $time  = (Get-Date -Format "HH-mm-ss")
            #Obtiene la fecha y hora actual con un formato apto para nombres.

            # Asegura que la carpeta exista y obtiene su ruta completa.
            $folderPath = New-FolderCreation -foldername $folder
            #Llama a la función anterior para crear la carpeta si falta.

            foreach ($n in $namesArray) {
                # Asegura que el nombre sea texto.
                $baseName = [string]$n

                #Construye el nombre final del archivo.
                $fileName = "${baseName}_${date1}_${time}.$Ext"

                # Calcula la ruta completa donde se ubicará el archivo.
                $fullPath = Join-Path -Path $folderPath -ChildPath $fileName

                # Crear el archivo y guarda su ruta si todo sale bien
                    # Una alternativa para no sobrescribir archivos existentes y puedes usar una condición para crear el archivo solo cuando realmente no esté creado aún.
                    New-Item -Path $fullPath -ItemType File -Force -ErrorAction Stop | Out-Null

                    # Si quieres, puedes escribir una línea inicial dentro del archivo para indicar la fecha en que se creó. Está desactivado por defecto, pero si lo activas, se agregará esa línea al final del archivo con la fecha actual.
                    $created += $fullPath # Se guarda la ruta del archivo recién creado en una lista. Esa lista sirve para saber, al final, qué archivos fueron creados con éxito.
                }
                catch { 
                    Write-Warning "Failed to create file '$fullPath' - $_" #Cuando ocurre un error al crear el archivo, entra aquí y muestra una advertencia indicando que no pudo crearse, junto con el error que ocurrió.
                }
            }

         return $created  #Devuelve la lista con todas las rutas de los archivos que sí se lograron crear.
        }

        "Message" {   #Indica que ahora se ejecutará la parte del código relacionada con escribir mensajes dentro de un archivo de log.
            #Obtiene la carpeta donde debería estar el archivo al que se quiere escribir el mensaje.
            $parent = Split-Path -Path $path -Parent
            if ($parent -and -not (Test-Path -Path $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            } #Si la carpeta no existe, la crea para asegurarse de que el archivo se puede escribir sin errores.

            $date = Get-Date #Obtiene la fecha y hora actual.
            $concatmessage = "|$date| |$message| |$Severity|" #Crea el texto final del mensaje que se escribirá en el log, incluyendo fecha, mensaje y nivel.

            switch ($Severity) { 
                "Information" { Write-Host $concatmessage -ForegroundColor Green }
                "Warning"     { Write-Host $concatmessage -ForegroundColor Yellow }
                "Error"       { Write-Host $concatmessage -ForegroundColor Red }
            } #Muestra el mensaje en la consola con un color distinto según el tipo de severidad: verde es información, amarillo es advertencia y rojo es error.

            # Agrega el mensaje al archivo indicado, si el archivo no existe, lo crea automáticamente.
            Add-Content -Path $path -Value $concatmessage -Force

            return $path #Devuelve la ruta del archivo al que se escribió el mensaje.
        }
        #Si se llama a la función con parámetros no válidos, lanza un error indicando que el conjunto de parámetros no existe.
        default {
            throw "Unknown parameter set: $($PsCmdlet.ParameterSetName)"
        }
    }
}

#Ejemplo de uso
#Llama a la función para crear un archivo de log dentro de una carpeta llamada “logs”.
$logPaths = Write-Log -Name "Name-Log" -folder "logs" -Ext "log" -Create
$logPaths
#Muestra las rutas de los archivos que fueron creados.