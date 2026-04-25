# Orbit Server

Express backend for AI flashcard generation, PDF processing, notifications, and leaderboard.

## Setup

### 1. Install dependencies
```bash
cd server
npm install
```

### 2. Add environment variables
```bash
cp .env.example .env
# Edit .env with your values
```

### 3. Add Firebase service account
- Go to Firebase Console → Project Settings → Service Accounts
- Click "Generate new private key"
- Save the file as `server/serviceAccountKey.json`
- **Never commit this file**

### 4. Get Gemini API key
- Go to https://aistudio.google.com/
- Create an API key
- Add it to `.env` as `GEMINI_API_KEY`

### 5. Run locally
```bash
npm run dev   # with nodemon (auto-restart)
npm start     # production
```

### 6. Deploy to Ubuntu VPS with PM2

```bash
# On your server
npm install -g pm2
cd /path/to/orbit/server
npm install
pm2 start app.js --name orbit-server
pm2 save
pm2 startup   # makes it restart on reboot
```

### 7. Nginx reverse proxy (optional but recommended)
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        client_max_body_size 25M;  # for PDF uploads
    }
}
```

## Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| GET | /health | Health check (no auth) |
| POST | /api/flashcards/generate | Generate AI flashcards for a topic |
| POST | /api/pdf/process | Upload PDF → chapter detection → flashcard generation |
| POST | /api/notifications/send | Send FCM push notification |
| POST | /api/leaderboard/update | Recalculate weekly rankings |

All `/api/*` routes require `Authorization: Bearer <Firebase ID Token>` header.

### POST `/api/flashcards/generate`
**Body (JSON):**
```json
{
  "topicId": "string",
  "topicName": "string",
  "domainId": "string",
  "subjectId": "string",
  "examTags": ["jee_mains"],
  "difficulty": "mixed"
}
```
Generates 30 flashcards and writes them to `domains/{domainId}/subjects/{subjectId}/topics/{topicId}/flashcards/`.
Skips generation if cards already exist.

### POST `/api/pdf/process`
**Body (multipart/form-data):**
```
pdf      — PDF file (max 20 MB)
uploadId — string (UUID, created by client)
topicName — string
domainId  — string
```
**Flow:**
1. Extracts text from PDF (pdf-parse)
2. Sends text to Gemini 1.5 Flash → detects 2–8 logical chapters
3. For each chapter, generates 5–12 flashcards (mix of types)
4. Writes to Firestore:
   - `uploads/{uploadId}/chapters/{chapterId}` — chapter title, order, cardCount
   - `uploads/{uploadId}/chapters/{chapterId}/cards/{cardId}` — individual cards
5. Updates `uploads/{uploadId}` with `status: 'completed'`, `pageCount`, `generatedCardCount`

**Response:**
```json
{
  "success": true,
  "cardCount": 48,
  "pageCount": 12,
  "chapterCount": 6
}
```

## Update Flutter .env
After deploying, update `.env` in the Flutter project root:
```
SERVER_BASE_URL=http://your-server-ip/api
```
