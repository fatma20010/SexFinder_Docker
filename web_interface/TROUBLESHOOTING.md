# Troubleshooting - Web Interface Not Accessible

## Error: "localhost n'autorise pas la connexion" (ERR_CONNECTION_REFUSED)

This means the web interface is not running. Here's how to fix it:

## Step 1: Start Docker Desktop

1. **Open Docker Desktop** application
2. **Wait** until it says "Docker is running" (green icon)
3. This may take 1-2 minutes

## Step 2: Start the Web Interface

Once Docker is running, open a terminal and run:

```powershell
cd C:\Users\msi\SexFindR\web_interface
docker-compose up -d
```

## Step 3: Verify Containers Are Running

Check if containers are running:

```powershell
docker-compose ps
```

You should see:
- `web_interface-frontend-1` - Status: Up
- `web_interface-backend-1` - Status: Up

## Step 4: Check Logs (If Still Not Working)

```powershell
# Check frontend logs
docker-compose logs frontend

# Check backend logs
docker-compose logs backend
```

## Step 5: Access the Interface

Once containers are running:
- Open browser: **http://localhost**
- Or try: **http://127.0.0.1**

## Common Issues

### Docker Desktop Not Running
- **Symptom**: ERR_CONNECTION_REFUSED
- **Fix**: Start Docker Desktop and wait for it to be ready

### Port 80 Already in Use
- **Symptom**: Container fails to start
- **Fix**: Change port in `docker-compose.yml`:
  ```yaml
  ports:
    - "8080:80"  # Use port 8080 instead
  ```
- Then access: http://localhost:8080

### Containers Not Starting
- **Check**: `docker-compose logs`
- **Fix**: Rebuild containers:
  ```powershell
  docker-compose down
  docker-compose build
  docker-compose up -d
  ```

## Quick Restart Command

If containers stopped:

```powershell
cd C:\Users\msi\SexFindR\web_interface
docker-compose restart
```

Or full restart:

```powershell
cd C:\Users\msi\SexFindR\web_interface
docker-compose down
docker-compose up -d
```

## Still Having Issues?

1. **Verify Docker Desktop is running** (check system tray)
2. **Check Docker Desktop settings** - ensure it's using enough resources
3. **Restart Docker Desktop** if needed
4. **Check firewall** - ensure ports 80 and 5000 are not blocked



