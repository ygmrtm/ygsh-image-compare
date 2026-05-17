#!/bin/bash

# =================================================================
# Nombre: procesador_imagenes.sh
# Finalidad: Extraer metadatos a CSV y limpiar imágenes en MacOS.
# Motores: exiftool (externo) o mdls (nativo).
# =================================================================

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <directorio> <motor: exiftool|mdls>"
    exit 1
fi

# Convert relative path to absolute
INPUT_FOLDER=$(cd "$1" || exit; pwd)
MODE="$2"

if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: El directorio no es válido."
    exit 1
fi

# Script directory for logs
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
LOGS_DIR="$SCRIPT_DIR/logs"
PROCESSED_LOG="$LOGS_DIR/metadatos_imagenes.log"
mkdir -p "$LOGS_DIR"
CSV_FILE="$LOGS_DIR/metadatos_imagenes.csv"
REPORT_FILE="$LOGS_DIR/reporte_imagenes.txt"

# Temp files
ALL_FILES="/tmp/all_files_$$.txt"

# Función para registrar logs
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$PROCESSED_LOG"
}

check_dependencies() {
    if [ "$MODE" == "exiftool" ]; then
        if ! command -v exiftool &> /dev/null; then
            log_message "Exiftool no encontrado. Intentando instalar con Homebrew..."
            if ! command -v brew &> /dev/null; then
                log_message "Instalando Homebrew primero..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install exiftool
        fi
    fi
}

# Find all images and videos
find "$INPUT_FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.heic" \)  > "$ALL_FILES"

total_files_found=$(wc -l < "$ALL_FILES" | tr -d ' ')

if [ "$total_files_found" -eq 0 ]; then
    echo "No media files found in $INPUT_FOLDER"
    #rm -f "$ALL_FILES"
    exit 0
fi

check_dependencies
start=$(date +%s)
log_message "=================================================== $(date)"
log_message "Input folder: $INPUT_FOLDER"
log_message "Iniciando proceso en modo: $MODE"
log_message "Archivos a procesar: $total_files_found"

# --- PASO 3: Procesamiento de archivos ---
count=0
if [ ! -f "$CSV_FILE" ]; then
    echo "Archivo,Latitud,Longitud,Equipo" > "$CSV_FILE"
fi
while IFS= read -r filea; do
    echo "Processing $filea"
    [ -z "$filea" ] && continue
    
    count=$((count + 1))
    percent=$(( count * 100 / total_files_found ))
    echo "----------------------------------------------------------------------"
    echo "$percent% [$count/$total_files_found] $filea"
    
    if [ "$MODE" == "exiftool" ]; then
        # Extraer datos
        DATA=$(exiftool -T -GPSLatitude -GPSLongitude -Model "$filea")
        
        # Check if sensitive metadata exists
        SENSITIVE_DATA=$(exiftool -s -S -GPSLatitude -GPSLongitude -Model "$filea")
        
        if [ -n "$SENSITIVE_DATA" ]; then
            echo "$filea,$DATA" | tr '\t' ',' >> "$CSV_FILE"
            # Limpiar (sobrescribir)
            exiftool -all= -overwrite_original "$filea" >> "$PROCESSED_LOG" 2>&1
            log_message "Ajustado (metadatos sensibles eliminados): $filea"
        else
            log_message "Omitido (sin metadatos sensibles): $filea"
        fi
        
    elif [ "$MODE" == "mdls" ]; then
        # Extraer datos usando mdls (nativo MacOS)
        LAT=$(mdls -name kMDItemLatitude "$filea" | awk '{print $3}')
        LON=$(mdls -name kMDItemLongitude "$filea" | awk '{print $3}')
        MOD=$(mdls -name kMDItemAcquisitionModel "$filea" | awk -F'"' '{print $2}')
        
        # Check if sensitive metadata exists
        if [ "$LAT" != "(null)" ] || [ "$LON" != "(null)" ] || [ -n "$MOD" ]; then
            echo "$filea,$LAT,$LON,$MOD" >> "$CSV_FILE"
            # Limpiar: mdls es solo lectura. Usamos xattr para quitar metadatos extendidos
            # y sips para forzar una resalida limpia de la imagen.
            xattr -c "$filea" >> "$PROCESSED_LOG" 2>&1
            sips -s format "$(echo ${filea##*.} | tr '[:upper:]' '[:lower:]')" "$filea" --out "$filea" >> "$PROCESSED_LOG" 2>&1
            log_message "Ajustado (metadatos sensibles eliminados): $filea"
        else
            log_message "Omitido (sin metadatos sensibles): $filea"
        fi
    fi

done < "$ALL_FILES"

echo "============================== $(date)" >> "$REPORT_FILE"
echo "REPORTE DE LIMPIEZA" >> "$REPORT_FILE"
echo "Motor utilizado: $MODE" >> "$REPORT_FILE"
echo "Imágenes procesadas: $count" >> "$REPORT_FILE"
echo "CSV generado: $CSV_FILE" >> "$REPORT_FILE"
echo "Total runtime: $(($(date '+%s') - start )) seconds" >> "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

tail -n 7 "$REPORT_FILE"

# Cleanup temp files
#rm -f "$ALL_FILES" 