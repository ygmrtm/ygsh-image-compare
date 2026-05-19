#!/bin/bash

# =================================================================
# Nombre: master_workflow.sh
# Finalidad: The One Ring to rule them all. Execute all scripts in cascade.
# =================================================================

echo "======================================================"
echo "Starting Master Workflow: Duplicate & Metadata Manager"
echo "======================================================"

# Step 1: run_find_duplicates.sh
echo "[1/3] Running find_duplicates workflow..."
if [ -x "./run_find_duplicates.sh" ]; then
    ./run_find_duplicates.sh
else
    bash ./run_find_duplicates.sh
fi

if [ $? -ne 0 ]; then
    echo "❌ Error: run_find_duplicates.sh failed. Aborting master workflow."
    exit 1
fi
echo "✅ run_find_duplicates.sh completed successfully."
echo "------------------------------------------------------"

# Step 2: run_move_old_Images.sh
echo "[2/3] Running move_old_images workflow..."
if [ -x "./run_move_old_Images.sh" ]; then
    ./run_move_old_Images.sh
else
    bash ./run_move_old_Images.sh
fi

if [ $? -ne 0 ]; then
    echo "❌ Error: run_move_old_Images.sh failed. Aborting master workflow."
    exit 1
fi
echo "✅ run_move_old_Images.sh completed successfully."
echo "------------------------------------------------------"

# Step 3: run_procesador_imagenes.sh
echo "[3/3] Running procesador_imagenes workflow..."
if [ -x "./run_procesador_imagenes.sh" ]; then
    ./run_procesador_imagenes.sh
else
    bash ./run_procesador_imagenes.sh
fi

if [ $? -ne 0 ]; then
    echo "❌ Error: run_procesador_imagenes.sh failed. Aborting master workflow."
    exit 1
fi
echo "✅ run_procesador_imagenes.sh completed successfully."
echo "======================================================"
echo "🎉 Master Workflow completed all steps successfully!"
echo "======================================================"
