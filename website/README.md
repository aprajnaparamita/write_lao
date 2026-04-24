# Write Lao - Cloudflare Workers Website

A Cloudflare Workers-based website for writelao.xyz with a public landing page and a teacher admin dashboard for managing course content.

## Structure

```
website/
├── src/
│   ├── website/
│   │   ├── index.ts           # Main worker entry point
│   │   └── landing-page.ts    # Landing page HTML/CSS/JS
│   ├── admin/
│   │   ├── router.ts          # Admin routes and auth
│   │   ├── admin-page.ts      # Admin dashboard HTML
│   │   └── course-handlers.ts # Vocabulary, lessons, audio handlers
│   └── lib/
│       └── auth.ts            # JWT auth utilities
├── wrangler.toml              # Cloudflare Workers config
├── package.json
└── tsconfig.json
```

## Features

### Public Landing Page (`/`)
- Full Write Lao marketing page
- Responsive, accessible design
- Download links for all platforms
- FAQ, pricing, feature sections

### Admin Dashboard (`/admin/`)
- **Vocabulary Management** - Review and edit 500 words with examples and audio
- **Lesson Management** - Alphabet lessons structure
- **Audio Recording** - Record native speaker pronunciation
- **Example Editing** - Edit example sentences for vocabulary
- **Export Bundle** - Generate course data for app integration

## Setup

```bash
cd website
npm install
```

## Configuration

1. **Create Cloudflare resources:**
   ```bash
   # Create KV namespace for assets cache
   wrangler kv:namespace create ASSETS

   # Create D1 database for teacher accounts and content
   wrangler d1 create writelao-db

   # Create R2 bucket for course data (audio, images)
   wrangler r2 bucket create writelao-course-data
   ```

2. **Update `wrangler.toml`** with the actual IDs from the commands above.

3. **Set secrets:**
   ```bash
   wrangler secret put TEACHER_JWT_SECRET
   wrangler secret put ADMIN_EMAIL
   ```

## Development

```bash
npm run dev    # Start local dev server
```

Visit http://localhost:8787

## Deployment

```bash
npm run deploy    # Deploy to Cloudflare
```

## Environment Variables

| Variable | Description |
|---|---|
| `TEACHER_JWT_SECRET` | Secret key for signing teacher session tokens |
| `ADMIN_EMAIL` | Email address for teacher login verification |
| `ENVIRONMENT` | Set to "production" in production |

## Admin Login

The admin dashboard uses JWT authentication:
- Default test login: `admin@writelao.xyz` / `admin123`
- Tokens are HTTP-only cookies with 1-hour expiry
- Refresh tokens last 7 days

## TODO

- [ ] Connect to real D1 database for teacher accounts
- [ ] Integrate R2 for audio file storage
- [ ] Implement Google OAuth for teacher login
- [ ] Add real vocabulary/lesson/audio data from `prompts/data/`
- [ ] Add audio upload to R2 from admin dashboard
- [ ] Export bundle generation that pulls from D1/R2