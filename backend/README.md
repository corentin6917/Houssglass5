# Hourglass Backend API

FastAPI backend for auto-evaluation, devaluation logic, and social interactions.

## Setup

1. Create virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Edit `.env` with your credentials:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret
DATABASE_URL=postgresql://postgres:password@db.xxx.supabase.co:5432/postgres
```

## Running

```bash
# Development (with auto-reload)
uvicorn app.main:app --reload

# Production
uvicorn app.main:app --host 0.0.0.0 --port 8000

# With custom host/port
uvicorn app.main:app --host 127.0.0.1 --port 8080
```

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Endpoints

### Goals
- `POST /api/goals/evaluate`: Auto-evaluate goals and assign grain values
- `POST /api/goals/devaluate`: Calculate devalued grain value for repeated goals

### Social
- `POST /api/social/boost`: Send an Éclat de Grain (0.2 grain)
- `POST /api/social/transfusion`: Send heritage grain (1.0 grain)
- `POST /api/social/comment`: Post a comment (0.1 grain cost)

### Health
- `GET /`: Root endpoint
- `GET /health`: Health check

## Project Structure

```
app/
├── api/                # API endpoints
│   ├── goals.py        # Goal evaluation
│   └── social.py       # Social interactions
├── core/               # Core configuration
│   ├── config.py       # Settings
│   ├── db.py           # Database
│   └── auth.py         # JWT verification
├── services/           # Business logic
│   ├── auto_valuation.py  # Goal valuation
│   ├── devaluation.py      # Devaluation logic
│   ├── ratio.py            # Ratio calculation
│   ├── phoenix.py          # Phoenix Mode
│   └── seasons.py          # Life Seasons
└── main.py             # FastAPI app
```

## Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test
pytest tests/test_devaluation.py
```

## Authentication

All endpoints (except / and /health) require a valid Supabase JWT token in the Authorization header:

```
Authorization: Bearer <your-supabase-jwt-token>
```

The token is verified using the Supabase JWT secret and the user ID is extracted for authorization.

## Environment Variables

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_KEY`: Service role key (has admin access)
- `SUPABASE_JWT_SECRET`: JWT secret for token verification
- `DATABASE_URL`: PostgreSQL connection string
- `APP_ENV`: `development` or `production`
- `API_HOST`: Host to bind to (default: 0.0.0.0)
- `API_PORT`: Port to bind to (default: 8000)

## Deployment

For production deployment:

1. Set `APP_ENV=production` in `.env`
2. Use a production WSGI server (uvicorn with workers)
3. Set up HTTPS with a reverse proxy (nginx)
4. Configure CORS allowed origins in `main.py`

```bash
# Production with multiple workers
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```
