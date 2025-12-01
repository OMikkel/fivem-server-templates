# FiveM Development Server

A Docker-based FiveM development server for local testing and resource development. This setup provides an isolated, reproducible FiveM server environment with automatic framework initialization and database management.

## Directory Structure

```
fivem-dev-server/
├── docker-compose.yml      # Container orchestration configuration
├── Dockerfile               # FiveM server container build instructions
├── cpuinfo_hack.txt        # CPU info file for ARM compatibility workaround
├── scripts/
│   └── entrypoint.sh       # Server initialization and startup script
└── templates/
    └── qbcore/             # QBCore framework template
        ├── init.sh         # Framework-specific initialization script
        ├── server.cfg      # FiveM server configuration
        └── database.sql    # Initial database schema
```

## File Descriptions

### Root Files

| File | Description |
|------|-------------|
| `docker-compose.yml` | Defines the multi-container setup including the FiveM server and MariaDB database. Configures networking, volumes, and environment variables. |
| `Dockerfile` | Builds the FiveM server image based on Debian. Downloads FiveM artifacts and sets up the runtime environment. |
| `cpuinfo_hack.txt` | A mock CPU info file used to work around FiveM's CPU detection on ARM-based systems (e.g., Apple Silicon Macs running via emulation). |

### Scripts

| File | Description |
|------|-------------|
| `scripts/entrypoint.sh` | Main entrypoint script that waits for the database, runs framework initialization on first boot, and starts the FiveM server. |

### Templates

Templates contain framework-specific configurations and initialization scripts.

| File | Description |
|------|-------------|
| `templates/qbcore/init.sh` | QBCore initialization script that copies template files to the server data directory and imports the database schema. |
| `templates/qbcore/server.cfg` | FiveM server configuration file for QBCore. Define your server name, resources, convars, and other server settings here. |
| `templates/qbcore/database.sql` | SQL file containing the initial database schema for QBCore. Automatically imported on first server start. |

## Configuration

### Environment Variables

Configure these in `docker-compose.yml` under the `fivem-server` service:

| Variable | Description | Default |
|----------|-------------|---------|
| `FRAMEWORK` | The framework template to use (e.g., `qbcore`) | `qbcore` |
| `SV_LICENSE_KEY` | Your FiveM license key from [keymaster.fivem.net](https://keymaster.fivem.net) | **Required** |
| `DB_HOST` | Database hostname | `db` |
| `DB_USER` | Database username | `root` |
| `DB_PASSWORD` | Database password | `root` |
| `DB_NAME` | Database name | `fivem_db` |

### Build Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `FXSERVER_VER` | FiveM artifacts version to download | `17000-e0ef7490f76a24505b8bac7065df2b7075e610ba` |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `30120` | TCP/UDP | Main FiveM game server port |
| `40120` | TCP | txAdmin web interface (if enabled) |

### Volumes

| Volume | Description |
|--------|-------------|
| `./server-data` | Persistent server data directory. Contains resources, server.cfg, and cache. |
| `./templates` | Framework templates (read-only mount). |
| `fivem-db-data` | Named volume for MariaDB data persistence. |

## 🚀 Quick Start

1. **Get a FiveM License Key**
   
   Register at [keymaster.fivem.net](https://keymaster.fivem.net) and generate a server key.

2. **Configure your license key**
   
   Edit `docker-compose.yml` and replace `<LICENSEKEY>` with your actual key:
   ```yaml
   environment:
     - SV_LICENSE_KEY=your_license_key_here
   ```

3. **Start the server**
   ```bash
   docker-compose up -d
   ```

4. **View logs**
   ```bash
   docker-compose logs -f fivem-server
   ```

5. **Connect to the server**
   
   Open FiveM and connect to `localhost:30120`

## 🛠️ Adding Custom Resources

1. Place your resources in `./server-data/resources/`
2. Add `ensure your_resource_name` to `./server-data/server.cfg`
3. Restart the server: `docker-compose restart fivem-server`

## 📝 Adding a New Framework Template

1. Create a new folder under `templates/` (e.g., `templates/esx/`)
2. Add an `init.sh` script that handles:
   - Copying configuration files
   - Database initialization
   - Any framework-specific setup
3. Add a `server.cfg` with your server configuration
4. Add a `database.sql` with required database tables
5. Set `FRAMEWORK=esx` in `docker-compose.yml`

## 🔧 Useful Commands

```bash
# Start the server
docker-compose up -d

# Stop the server
docker-compose down

# View live logs
docker-compose logs -f fivem-server

# Restart the server
docker-compose restart fivem-server

# Reset server (removes all data)
docker-compose down -v
rm -rf ./server-data/*

# Rebuild after Dockerfile changes
docker-compose build --no-cache
docker-compose up -d

# Access server shell
docker exec -it fivem-server bash

# Access database
docker exec -it fivem-db mariadb -uroot -proot fivem_db
```

## ⚠️ Notes

- **ARM/Apple Silicon**: The container runs in AMD64 emulation mode on ARM systems. This may impact performance but ensures compatibility.
- **First Boot**: The first startup takes longer as it initializes the framework and imports the database.

## 📋 Requirements

- Docker Desktop or Docker Engine
- Docker Compose v2+
- FiveM License Key
- ~2GB disk space for artifacts and resources
