# Script por: Oscar de la Cuesta
# Twitter: @oscardelacuesta
# Fecha: 16-06-2024
# Versi�n: 1.1

# Par�metros de entrada: $source (ruta del archivo de origen) y $destination (ruta del archivo de destino)
param (
    [string]$source,
    [string]$destination
)

# Verificar si los par�metros est�n definidos y no est�n vac�os
if (-not $source -or -not $destination) {
    Write-Host "Debe proporcionar tanto la ruta del archivo de origen como la del archivo de destino." -ForegroundColor Red
    Write-Host "Uso: .\copiar.ps1 -source <ruta_del_archivo_de_origen> -destination <ruta_del_archivo_de_destino>" -ForegroundColor Yellow
    Write-Host "Ejemplo: .\copiar.ps1 -source \"C:\contoso db\ContosoRetailDW.bak\" -destination \"C:\ruta\al\destino\archivo_grande.iso\"" -ForegroundColor Yellow
    exit 1
}

# Verificar si el archivo de origen existe
if (-not (Test-Path $source)) {
    Write-Host "El archivo de origen no existe." -ForegroundColor Red
    exit 1
}

# Verificar si el destino no es un directorio
if (Test-Path $destination) {
    $destItem = Get-Item $destination
    if ($destItem.PSIsContainer) {
        Write-Host "La ruta de destino no puede ser un directorio." -ForegroundColor Red
        exit 1
    }
}

# Tama�o del buffer para la copia
$bufferSize = 1MB

# Manejo de excepciones durante la operaci�n de copia
try {
    # Abrir el archivo de origen para lectura
    $inStream = [System.IO.File]::OpenRead($source)
    # Abrir el archivo de destino para escritura
    $outStream = [System.IO.File]::OpenWrite($destination)
    
    # Crear un buffer de bytes del tama�o especificado
    $buffer = New-Object byte[] $bufferSize
    $totalRead = 0
    $totalLength = $inStream.Length

    # Bucle para leer y escribir el archivo en bloques
    while ($true) {
        # Leer un bloque del archivo de origen
        $read = $inStream.Read($buffer, 0, $bufferSize)
        if ($read -le 0) { break }

        # Escribir el bloque en el archivo de destino
        $outStream.Write($buffer, 0, $read)
        $totalRead += $read

        # Calcular el porcentaje completado y mostrar progreso en bytes
        $percent = [math]::Round(($totalRead / $totalLength) * 100, 2)
        Write-Progress -Activity "Copiando archivo..." -Status "$percent% completado ($totalRead bytes de $totalLength bytes)" -PercentComplete $percent
    }
    
    # Mostrar mensaje de �xito
    Write-Host "Archivo copiado exitosamente." -ForegroundColor Green

} catch {
    # Manejo de cualquier error que ocurra durante la copia
    Write-Host "Ocurri� un error durante la copia: $_" -ForegroundColor Red
} finally {
    # Asegurarse de cerrar los flujos de archivo
    if ($inStream) { $inStream.Close() }
    if ($outStream) { $outStream.Close() }
}
