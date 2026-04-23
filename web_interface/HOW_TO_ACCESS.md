# How to Access the SexFindR Web Interface

## 🌐 Access the Interface

### Step 1: Open Your Web Browser

Open any modern web browser:
- **Chrome** (recommended)
- **Firefox**
- **Edge**
- **Safari** (on Mac)

### Step 2: Go to the URL

Type this in your browser's address bar:

```
http://localhost
```

Or click this link: [http://localhost](http://localhost)

### Step 3: You Should See

You should see the SexFindR interface with:
- A header showing "🧬 SexFindR"
- Upload section for files
- Configuration options
- Run pipeline button

## 🔍 If It Doesn't Work

### Check if Services Are Running

Open a terminal/command prompt and run:

```bash
docker-compose ps
```

You should see both `frontend` and `backend` containers running.

### Check Logs

If something is wrong, check the logs:

```bash
docker-compose logs frontend
docker-compose logs backend
```

### Try Alternative URLs

If `http://localhost` doesn't work, try:
- `http://127.0.0.1`
- `http://localhost:80`

### Check Port Conflicts

If port 80 is already in use, you can change it in `docker-compose.yml`:

```yaml
ports:
  - "8080:80"  # Change to use port 8080 instead
```

Then access at: `http://localhost:8080`

## 📱 Access from Another Device on Same Network

If you want to access from another computer/phone on the same network:

1. Find your computer's IP address:
   - **Windows**: Run `ipconfig` and look for IPv4 Address
   - **Mac/Linux**: Run `ifconfig` or `ip addr`

2. Update `docker-compose.yml` to bind to all interfaces:
   ```yaml
   ports:
     - "0.0.0.0:80:80"  # Instead of just "80:80"
   ```

3. Restart: `docker-compose restart frontend`

4. Access from other device: `http://YOUR_IP_ADDRESS`

## 🎯 Quick Test

To verify everything is working:

1. Open browser → `http://localhost`
2. You should see the SexFindR interface
3. Check browser console (F12) for any errors
4. Try the health check: `http://localhost:5000/api/health`

## ✅ Success Indicators

- ✅ Interface loads in browser
- ✅ No error messages
- ✅ Upload area is visible
- ✅ Status indicator shows "Ready"

## 🆘 Still Having Issues?

1. **Restart the services:**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

2. **Check Docker Desktop:**
   - Make sure Docker Desktop is running
   - Check system tray (Windows) or menu bar (Mac)

3. **View detailed logs:**
   ```bash
   docker-compose logs -f
   ```

4. **Verify ports are free:**
   - Windows: `netstat -an | findstr :80`
   - Mac/Linux: `lsof -i :80`




