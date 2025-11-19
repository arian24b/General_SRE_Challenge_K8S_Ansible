# IP Geolocation API

A FastAPI-based service for IP geolocation with caching using PostgreSQL.

## Features

- IP geolocation lookup with external API integration
- Database caching for improved performance
- Prometheus metrics for monitoring
- Health check endpoint
- CORS support
- Comprehensive test suite

## Prerequisites

- Python 3.14+
- PostgreSQL database
- uv package manager

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   uv sync
   ```

3. Copy `.env` and configure environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

## Configuration

The application uses the following environment variables:

- `DB_USER`: PostgreSQL username
- `DB_PASSWORD`: PostgreSQL password
- `DB_HOST`: PostgreSQL host
- `DB_PORT`: PostgreSQL port
- `DB_NAME`: PostgreSQL database name
- `DEBUG`: Enable debug mode (true/false)
- `HOST`: Server host (default: 0.0.0.0)
- `PORT`: Server port (default: 8000)
- `IP_API_URL`: External IP geolocation API URL

## Running the Application

### Development
```bash
uv run python main.py
```

### Production
```bash
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Or using Docker:
```bash
docker build -t ip-geolocation-api .
docker run -p 8000:8000 ip-geolocation-api
```

## API Endpoints

- `GET /geolocate/{ip}`: Get country for IP address
- `GET /health`: Health check
- `GET /metrics`: Prometheus metrics
- `GET /docs`: API documentation (Swagger UI)

## Development Setup

1. Install pre-commit hooks:
   ```bash
   uv run pre-commit install
   ```

2. Run linting:
   ```bash
   uv run ruff check .
   uv run mypy .
   ```

3. Run tests with coverage:
   ```bash
   uv run pytest --cov=app --cov-report=html
   ```

## Deployment

### Docker

Build and run with Docker:
```bash
docker build -t ip-geolocation-api .
docker run -p 8000:8000 --env-file .env ip-geolocation-api
```

### Kubernetes

Use the provided Kubernetes manifests in the `k8s/` directory (if available).

## API Documentation

Once running, visit `http://localhost:8000/docs` for interactive API documentation.

## Monitoring

The application exposes Prometheus metrics at `/metrics` including:
- Request count by method, endpoint, and status
- Request latency histograms

## Health Checks

The `/health` endpoint returns `{"status": "healthy"}` when the service is running.

## Database Migrations

Database migrations are managed with Alembic and located in `app/db/migrations/`.

To create a new migration:
```bash
uv run alembic revision -m "Description of changes"
```

To run migrations:
```bash
uv run alembic upgrade head
```

To generate migrations automatically (requires database connection):
```bash
uv run alembic revision --autogenerate -m "Description"
```

## License

[Add license information]