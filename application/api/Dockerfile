FROM python:3.14-bookworm AS builder

ENV PATH="/root/.local/bin:${PATH}" PYTHONUNBUFFERED=1 UV_COMPILE_BYTECODE=1

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY ./pyproject.toml .

RUN uv lock; uv sync --frozen --no-cache --no-install-project --no-dev

FROM python:3.14-slim-bookworm AS production

LABEL maintainer="Arian <arianomrani24@gmail.com>"
LABEL description="IP Geolocation API"

WORKDIR /app

COPY ./ .
COPY --from=builder /app/.venv .venv

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONPATH="/app"

EXPOSE 8000

RUN groupadd -r appuser && useradd -r -g appuser appuser \
    && chown -R appuser:appuser /app

USER appuser

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]