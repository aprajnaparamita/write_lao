# Manual Tester Guide System

A video submission system for manual app testers. Testers record videos of each feature and submit them through a web interface. Admins can view all submissions and download videos grouped by device.

## Features

- **Tester Guide Page** (`/tester-guide`)
  - Step-by-step instructions for each feature
  - Video upload per section (record or upload)
  - **Direct-to-R2 upload** for files > 100 MB (bypasses Worker body limit)
  - Device info auto-collection
  - Progress tracking with checkboxes

- **Admin Dashboard** (`/admin/tester`)
  - View all video submissions
  - Filter by device model
  - Download individual videos
  - Download all videos for a device
  - Delete submissions

## Architecture: Two Upload Paths

CloudFlare Workers have a **100 MB request body limit**. To handle large video files:

| File Size | Path | How |
|-----------|------|-----|
| ≤ 100 MB  | Worker-proxied | `POST /api/tester/video` (multipart) → Worker → R2 |
| > 100 MB  | Direct-to-R2   | Pre-signed S3 PUT URL → browser uploads directly to R2 → Worker records metadata |

The client automatically chooses the right path based on file size.

## Setup

### 1. Run Database Migration

Apply the migration to create the `tester_submissions` table:

```bash
cd website
wrangler d1 execute writelao-db --file=migrations/0003_create_tester_submissions.sql
```

### 2. Configure R2 Bucket

The video storage uses the existing `COURSE_DATA` R2 bucket. Videos are stored with the prefix `tester-videos/`.

### 3. Create R2 API Token (for pre-signed URLs)

For direct-to-R2 uploads (files > 100 MB), the Worker generates pre-signed URLs. This requires an R2 API token:

1. Go to CloudFlare Dashboard → **R2** → **Manage R2 API Tokens**
2. Click **Create API Token**
3. Name it `write-lao-tester-uploads`
4. Permissions: **Object Read & Write**
5. Select the `writelao-course-data` bucket
6. Copy the **Access Key ID** and **Secret Access Key**
7. Set them as secrets:

```bash
wrangler secret put R2_ACCESS_KEY_ID
# Paste the Access Key ID

wrangler secret put R2_SECRET_ACCESS_KEY
# Paste the Secret Access Key
```

### 4. Set CloudFlare Account ID

Add your CloudFlare account ID to `wrangler.toml`:

```toml
[vars]
ACCOUNT_ID = "your-account-id-here"
```

Find it in your CloudFlare dashboard URL: `https://dash.cloudflare.com/<ACCOUNT_ID>`

### 5. Set Admin Password

The admin dashboard uses the same `TEACHER_JWT_SECRET` as the main admin:

```bash
wrangler secret put TEACHER_JWT_SECRET
# Enter a strong password when prompted
```

## Usage

### For Testers

1. Navigate to `/tester-guide`
2. Fill in device info (model, OS version, app version, your name)
3. For each section:
   - Read the steps
   - Check off completed items
   - Record or upload a video showing the feature
4. Submit all videos (or submit section-by-section)
5. **Large videos (> 100 MB) upload automatically via direct-to-R2** — no size issues

### For Admins

1. Navigate to `/admin/tester`
2. Log in with the admin password
3. View submissions grouped by device
4. Download videos as needed

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/tester/presign-upload` | POST | Generate a pre-signed R2 PUT URL (for files > 100 MB) |
| `/api/tester/video-complete` | POST | Record metadata after direct R2 upload completes |
| `/api/tester/video` | POST | Upload a video ≤ 100 MB (worker-proxied, multipart) |
| `/api/tester/submissions` | GET | Get all submissions |
| `/api/tester/devices` | GET | Get unique device list |
| `/api/tester/filters` | GET | Get filter options for admin drill-downs |
| `/api/tester/video/:key` | GET | Download a video file from R2 |
| `/api/tester/submission/:id` | DELETE | Delete a submission |

## Video Storage

Videos are stored in R2 at `tester-videos/{timestamp}_{deviceModel}_{section}.mp4`

Metadata is stored in D1 with the following schema:

```sql
CREATE TABLE tester_submissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  filename TEXT NOT NULL,
  section TEXT NOT NULL,
  device_model TEXT NOT NULL,
  os_version TEXT NOT NULL,
  app_version TEXT NOT NULL,
  tester_name TEXT NOT NULL,
  uploaded_at TEXT NOT NULL
);
```

## Troubleshooting Large Uploads

### Symptom: 149 MB file fails to upload

**Root cause**: CloudFlare Workers have a 100 MB request body limit. If a file > 100 MB hits the legacy `POST /api/tester/video` endpoint, it's rejected by the Workers runtime before your code runs.

**Fix (already implemented)**: The client now detects files > 100 MB and uses the direct-to-R2 path. Make sure:
- `ACCOUNT_ID` is set in `wrangler.toml`
- `R2_ACCESS_KEY_ID` and `R2_SECRET_ACCESS_KEY` secrets are set
- The R2 API token has **Object Read & Write** permissions on the `writelao-course-data` bucket

### CORS errors on direct upload

If the browser gets CORS errors when PUT-ing to R2, configure CORS on the bucket:

```bash
# Create CORS config file
cat > r2-cors.json << 'EOF'
{
  "cors_rules": [
    {
      "allowed_origins": ["https://writelao.xyz", "http://localhost:8787"],
      "allowed_methods": ["PUT", "GET"],
      "allowed_headers": ["Content-Type"],
      "max_age_seconds": 3600
    }
  ]
}
EOF

# Apply it
wrangler r2 bucket cors set writelao-course-data ./r2-cors.json

# Verify
wrangler r2 bucket cors list writelao-course-data
```

## Security

- Admin dashboard requires authentication
- Video upload endpoint validates file type and size
- Pre-signed URLs expire after 1 hour
- Files are served with proper content-type headers
- No PII stored beyond tester name
- R2 files are not publicly accessible (served only through Worker)
