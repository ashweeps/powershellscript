Add-Type -AssemblyName System.Windows.Forms #Cargan librerías de .NET, System.Windows.Forms permite crear ventanas, botones, cajas de texto
Add-Type -AssemblyName System.Drawing #Cargan librerías de .NET, System.Drawing permite usar tamaños, colores, fuentes, posiciones, etc.
#Crea la ventana (formulario). New-Object Form, crea una ventana vacía. Text, título de la ventana. .Size, tamaño del formulario. .StartPosition hace que la ventana aparezca centrada en pantalla.
$form = New-Object System.Windows.Forms.Form
$form.Text = "Input Form"
$form.Size = New-Object System.Drawing.Size(500,250)
$form.StartPosition = "CenterScreen"

#Crea etiquetas 
$textLabel1 = New-Object System.Windows.Forms.Label
$textLabel1.Text = "Input 1:"
$textLabel1.Left = 20
$textLabel1.Top = 20
$textLabel1.Width = 120
#Crea un label

$textLabel2 = New-Object System.Windows.Forms.Label
$textLabel2.Text = "Input 2:"
$textLabel2.Left = 20
$textLabel2.Top = 60
$textLabel2.Width = 120
#Crea un label2
$textLabel3 = New-Object System.Windows.Forms.Label
$textLabel3.Text = "Input 3:"
$textLabel3.Left = 20
$textLabel3.Top = 100
$textLabel3.Width = 120
#Crea un label3

#Crear las 3 cajas de texto
$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Left = 150
$textBox1.Top = 20
$textBox1.Width = 200
#Caja de texto 1

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Left = 150
$textBox2.Top = 60
$textBox2.Width = 200
#Caja de texto 2

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Left = 150
$textBox3.Top = 100
$textBox3.Width = 200
#Caja de texto 
#Se define un valor vacío. Este valor se coloca en los 3 cuadros de texto.
$defaultValue = ""
$textBox1.Text = $defaultValue
$textBox2.Text = $defaultValue
$textBox3.Text = $defaultValue

#Ubicado en la parte inferior derecha, con el texto "OK" y anchura de 100px.
$button = New-Object System.Windows.Forms.Button
$button.Left = 360
$button.Top = 140
$button.Width = 100
$button.Text = "OK"

#Cuando se hace clic en el botón: se guarda un hash table en form.Tag con los valores escritos y la ventana se cierra.
$button.Add_Click({
    $form.Tag = @{
        Box1 = $textBox1.Text
        Box2 = $textBox2.Text
        Box3 = $textBox3.Text
    }
    $form.Close()
})

#gregar todos los controles a la ventana, esto hace que: los labels, los textboxes y el botón, aparezcan dentro la ventana.
$form.Controls.Add($button)
$form.Controls.Add($textLabel1)
$form.Controls.Add($textLabel2)
$form.Controls.Add($textLabel3)
$form.Controls.Add($textBox1)
$form.Controls.Add($textBox2)
$form.Controls.Add($textBox3)
#Muestra la ventana y espera hasta que el usuario haga clic en OK. Out-Null es para que no muestre basura en la consola.
$form.ShowDialog() | Out-Null
#Cuando la ventana se cierra, se devuelven los valores ingresados en las tres cajas de texto. El resultado final es una lista de 3 valores.
return $form.Tag.Box1, $form.Tag.Box2, $form.Tag.Box3