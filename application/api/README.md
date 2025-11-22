# IP Geolocation API

A FastAPI-based service for IP geolocation with caching using PostgreSQL.

## Features
- IP geolocation lookup with external API integration
- Database caching for improved performance
- Prometheus metrics for monitoring
- Health check endpoint
- CORS support
- Comprehensive test suite
- Python 3.14+
- PostgreSQL async database
- uv package manager

## Installation
```bash
uv sync
cp .env.example .env
```

## Configuration
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
or
```bash
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000
```
Or
```bash
docker build -t ip-geolocation-api .
docker run -p 8000:8000 ip-geolocation-api
```

## API Endpoints

- `GET /geolocate/{ip}`: Get country for IP address
- `GET /health`: Health check
- `GET /metrics`: Prometheus metrics
- `GET /docs`: API documentation (Swagger UI)