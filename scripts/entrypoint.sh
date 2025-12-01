#!/bin/bash
set -e

# Global Paths
DATA_DIR="/opt/fivem/server-data"
TEMPLATE_BASE="/opt/fivem/templates"

echo "--- FiveM Docker Controller ---"

# 1. Wait for Database to be ready
# We use mysqladmin ping to check if the DB container is accepting connections
echo "Waiting for Database ($DB_HOST)..."
until mariadb-admin ping -h"$DB_HOST" --silent; do
    echo "DB not ready, sleeping..."
    sleep 2
done
echo "Database is UP!"

# 2. Check if Server is already initialized
if [ -f "$DATA_DIR/server.cfg" ]; then
    echo "server.cfg found. Skipping initialization."
else
    echo "No server.cfg found. Starting initialization for: $FRAMEWORK"
    
    FRAMEWORK_INIT="$TEMPLATE_BASE/$FRAMEWORK/init.sh"

    if [ -f "$FRAMEWORK_INIT" ]; then
        echo "Found init script for $FRAMEWORK. Executing..."
        
        # Pass control to the framework specific script
        # We run it with bash explicitly to avoid permission issues on mounted volumes
        bash "$FRAMEWORK_INIT"
        
        echo "$FRAMEWORK initialization finished."
    else
        echo "ERROR: No init.sh found for framework '$FRAMEWORK' at $FRAMEWORK_INIT"
        exit 1
    fi
fi

# 3. Start the FiveM Server
echo "Starting FXServer..."
exec /bin/bash /opt/fivem/run.sh +exec server.cfg +set sv_licenseKey "$SV_LICENSE_KEY"