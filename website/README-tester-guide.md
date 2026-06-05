# Manual Tester Guide System

A video submission system for manual app testers. Testers record videos of each feature and submit them through a web interface. Admins can view all submissions and download videos grouped by device.

## Features

- **Tester Guide Page** (`/tester-guide`)
  - Step-by-step instructions for each feature
  - Video upload per section (record or upload)
  - Device info auto-collection
  - Progress tracking with checkboxes
  
- **Admin Dashboard** (`/admin/tester`)
  - View all video submissions
  - Filter by device model
  - Download individual videos
  - Download all videos for a device
  - Delete submissions

## Setup

### 1. Run Database Migration

Apply the migration to create the `tester_submissions` table:

```bash
cd website
wrangler d1 execute writelao-db --file=migrations/0003_create_tester_submissions.sql
```

###2. Configure R2 Bucket

The video storage uses the existing `COURSE_DATA` R2 bucket. Videos are stored with the prefix `tester-videos/`.

### 3. Set Admin Password

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

### For Admins

1. Navigate to `/admin/tester`
2. Log in with the admin password
3. View submissions grouped by device
4. Download videos as needed

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/tester/video` | POST | Upload a video (multipart form) |
| `/api/tester/submissions` | GET | Get all submissions |
| `/api/tester/devices` | GET | Get unique device list |
| `/api/tester/video/:key` | GET | Download a video file |
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

## Device Grouping

Videos are automatically grouped by device model and OS version for easy download. Example filenames:

- `1709742000000_iPhone_15_Pro_Max_launch.mp4`
- `1709742000000_iPad_13_2026_vocab.mp4`
- `1709742000000_Pixel_8_Android_offline.mp4`

## Security

- Admin dashboard requires authentication
- Video upload endpoint validates file type and size
- Files are served with proper content-type headers
- No PII stored beyond tester name

## Future Enhancements

- [ ] Generate ZIP files server-side for batch downloads
- [ ] FFmpeg integration to concatenate videos per device
- [ ] Email notifications when new submissions arrive
- [ ] Video compression before storage
- [ ] Automatic video format conversion
- [ ] Bulk export by date range
