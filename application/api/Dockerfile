FROM python:3.14-bookworm AS builder

ENV PATH="/root/.local/bin:${PATH}" PYTHONUNBUFFERED=1 UV_COMPILE_BYTECODE=1

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY ./pyproject.toml .

RUN uv lock; uv sync --frozen --no-cache --no-install-project --no-dev

FROM python:3.14-slim-bookworm AS production

WORKDIR /app

COPY ./ .
COPY --from=builder /app/.venv .venv

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 CMD curl -f http://localhost:8000/ || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]