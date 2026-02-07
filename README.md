# UniMatch 🎓

**University Study Buddy Matching Platform** — A Rails 8 web app that helps university students find compatible study partners based on courses, study styles, and availability.

🌐 **Live Demo:** [unimatch-cvd8.onrender.com](https://unimatch-cvd8.onrender.com)

---

## Features

- 🔐 **Authentication** — Sign up / login with BCrypt secure passwords
- 📝 **Profile Management** — Faculty, year, strong/weak subjects, study style, preferred time, bio
- 🤝 **Smart Matching** — AI-powered compatibility matching by subject & study preferences
- 💬 **Real-time Chat** — WebSocket chat via Action Cable (Turbo Streams, per-user broadcasting)
- 🤖 **AI Tutor** — Dedicated AI chat room powered by Groq (LLaMA 3.3 70B) for study Q&A
- 🧊 **AI Icebreakers** — Auto-generated conversation starters when you match
- 🎭 **Anonymous → Reveal** — Chat anonymously first, then reveal your real identity when ready
- 👤 **Partner Profile** — View your match's full profile (bio, subjects, study style, reviews)
- ⭐ **Review & Rating** — Rate your study buddy (1–5 stars) after chatting
- ✅ **Read Receipts** — See "อ่านแล้ว ✓✓" when your partner reads your messages
- 📱 **Fully Responsive** — Mobile-first design with dedicated mobile & desktop navigation
- 🎨 **Minimal Theme** — Clean UI with DiceBear avatars, Font Awesome icons, SweetAlert2 alerts

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Ruby 3.3.6 |
| **Framework** | Rails 8.1.2 |
| **Database** | PostgreSQL (production) · SQLite (development) |
| **CSS** | Tailwind CSS v4 via `tailwindcss-rails` |
| **JS** | Hotwire (Turbo + Stimulus) · Importmap |
| **Real-time** | Action Cable (`async` adapter) |
| **AI** | Groq API (`llama-3.3-70b-versatile`) |
| **Font** | Kanit (Google Fonts) |
| **Icons** | Font Awesome 6 CDN |
| **Avatars** | DiceBear Adventurer |
| **Alerts** | SweetAlert2 |
| **Server** | Puma |
| **Hosting** | Render.com (free tier) |

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
# Edit .env and add your GROQ_API_KEY (get one at https://console.groq.com/)

# Start server
bin/dev
```

Visit `http://localhost:3000`

### Seed Accounts

| Email | Password | Role |
|---|---|---|
| `alice@example.com` | `password123` | Student (strong: Math) |
| `bob@example.com` | `password123` | Student (strong: Physics) |
| `carol@example.com` | `password123` | Student (strong: English) |
| `dave@example.com` | `password123` | Student (strong: Chemistry) |
| `eve@example.com` | `password123` | Student (strong: Programming) |

---

## Deploy to Render

### One-Click Blueprint

1. Fork this repo
2. Go to [Render Dashboard](https://dashboard.render.com)
3. Click **New** → **Blueprint**
4. Connect your GitHub repo — Render will detect `render.yaml`
5. Set the manual env vars when prompted:
   - `RAILS_MASTER_KEY` — contents of `config/master.key`
   - `GROQ_API_KEY` — your Groq API key from [console.groq.com](https://console.groq.com/)

### Environment Variables (Render)

| Variable | Value |
|---|---|
| `DATABASE_URL` | Auto-set from Render PostgreSQL |
| `RAILS_ENV` | `production` |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` |
| `SECRET_KEY_BASE` | Auto-generated |
| `GROQ_API_KEY` | Your Groq API key |
| `WEB_CONCURRENCY` | `0` (single process for async Action Cable) |
| `RAILS_MAX_THREADS` | `5` |

---

## Testing

```bash
rails test          # 139 tests, 399 assertions, 0 failures
```

Test coverage includes:
- Model validations & associations
- Controller actions & authorization
- AI service integration
- Review system
- Read receipts
- Partner profile access

---

## Project Structure

```
app/
├── controllers/     # Auth, dashboard, matches, chat, messages, reviews, profiles
├── models/          # User, ChatRoom, ChatRoomMembership, Message, Review
├── services/        # AiService (Groq API integration)
├── jobs/            # AiResponseJob (async AI replies)
├── views/           # ERB templates with Tailwind CSS
└── javascript/      # Stimulus controllers
config/
├── routes.rb        # RESTful routes
├── cable.yml        # Action Cable (async adapter)
└── importmap.rb     # JS dependencies
db/
├── migrate/         # 7 migrations
├── schema.rb        # Current schema
└── seeds.rb         # 5 demo users with profiles
```

---

## License

MIT
