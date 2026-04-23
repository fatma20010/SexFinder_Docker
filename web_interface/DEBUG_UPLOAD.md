# Debug Upload Issues

## If FASTQ Files Don't Appear After Upload

### Step 1: Check Browser Console

1. Open browser developer tools (F12)
2. Go to "Console" tab
3. Try uploading a file
4. Look for any error messages (in red)

### Step 2: Check Network Tab

1. In developer tools, go to "Network" tab
2. Try uploading a file
3. Look for the `/api/upload` request
4. Check if it shows:
   - Status 200 (success) or error code
   - Response message

### Step 3: Check Backend Logs

```powershell
cd C:\Users\msi\SexFindR\web_interface
docker-compose logs backend --tail 50
```

Look for:
- "Upload request received"
- "File saved successfully"
- Any error messages

### Step 4: Verify Files Are Actually Saved

```powershell
# Check if files are in the uploads directory
dir C:\Users\msi\SexFindR\web_interface\uploads\data\fastq
```

### Common Issues

1. **File too large**: Check file size (max 10GB)
2. **Wrong file type**: Make sure file extension is .fastq, .fq, .fastq.gz, or .fq.gz
3. **CORS error**: Check browser console for CORS errors
4. **Network error**: Check if backend is running (http://localhost:5000/api/health)

### Quick Test

1. Open browser console (F12)
2. Try uploading a small test file
3. Check console for messages like:
   - "Uploading file: ..."
   - "Upload response: ..."
   - "Updated file display. Files: X"

### Manual Check

If files still don't show:

1. Go to: http://localhost:5000/api/files
2. You should see JSON with your files listed
3. If files are there but not showing in UI, it's a frontend issue
4. If files are NOT there, it's a backend/upload issue



