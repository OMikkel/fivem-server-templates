#!/bin/bash

# Define paths (inherited from main script or local)
SOURCE_DIR="/opt/fivem/templates/qbcore"
TARGET_DIR="/opt/fivem/server-data"

echo "[QBCore Init] Copying configuration files..."
cp -r $SOURCE_DIR/* $TARGET_DIR/
# Remove the init script itself from the server-data folder to keep it clean
rm "$TARGET_DIR/init.sh"

echo "[QBCore Init] Importing Database..."
# Check if a .sql file exists in the template folder
SQL_FILE="$TARGET_DIR/database.sql"

if [ -f "$SQL_FILE" ]; then
    # Import using environment variables passed from Docker Compose
    mariadb -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$SQL_FILE"
    echo "[QBCore Init] Database import successful."
    
    # Optional: Delete SQL file after import to save space/confusion
    # rm "$SQL_FILE"
else
    echo "[QBCore Init] Warning: database.sql not found, skipping DB import."
fi

# Optional: Clone resources if you aren't providing them in the template
# echo "[QBCore Init] Cloning QBCore framework..."
# git clone https://github.com/qbcore-framework/qb-core.git $TARGET_DIR/resources/qb-core