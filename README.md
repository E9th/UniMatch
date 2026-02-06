# UniMatch 🎓

**University Study Buddy Matching Platform** — A Rails 8 app that helps university students find compatible study partners based on courses, study styles, and availability.

## Features

- 🔐 User authentication (BCrypt)
- 📝 Profile management with study preferences
- 🤝 Smart matching algorithm based on compatibility
- 💬 Real-time chat with matched study buddies
- 🤖 AI-powered study tips (Gemini API)
- 📱 Fully responsive design (mobile-first)
- 🎨 Minimal theme with DiceBear avatars

## Tech Stack

- **Ruby** 3.2.10 / **Rails** 8.1.2
- **PostgreSQL** (production) / **SQLite** (development)
- **Tailwind CSS** v4 via tailwindcss-rails
- **Hotwire** (Turbo + Stimulus)
- **Font Awesome** 6 / **SweetAlert2** / **DiceBear** avatars

---

## Local Development

```bash
# Clone
git clone https://github.com/E9th/UniMatch.git
cd UniMatch

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Create .env from example
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

# Start server
bin/dev
```

Visit `http://localhost:3000`

---

## Deploy to Render

### Option A: One-Click Blueprint

1. Fork this repo
2. Go to [Render Dashboard](https://dashboard.render.com)
3. Click **New** → **Blueprint**
4. Connect your GitHub repo — Render will detect `render.yaml`
5. Set the manual env vars when prompted:
   - `RAILS_MASTER_KEY` — contents of `config/master.key`
   - `GEMINI_API_KEY` — your Google Gemini API key

### Option B: Manual Setup

1. **Create a PostgreSQL database** on Render (Free plan)
2. **Create a Web Service** on Render:
   - **Runtime:** Ruby
   - **Build Command:** `./bin/render-build.sh`
   - **Start Command:** `bundle exec puma -C config/puma.rb`
3. **Set Environment Variables:**

| Variable | Value |
|---|---|
| `DATABASE_URL` | Auto-set from Render PostgreSQL |
| `RAILS_ENV` | `production` |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` |
| `SECRET_KEY_BASE` | Generate with `rails secret` |
| `GEMINI_API_KEY` | Your Google Gemini API key |
| `SOLID_QUEUE_IN_PUMA` | `1` |
| `WEB_CONCURRENCY` | `2` |
| `RAILS_MAX_THREADS` | `5` |

---

## Testing

```bash
rails test                 # 121 tests, 341 assertions
```

---

## License

MIT
