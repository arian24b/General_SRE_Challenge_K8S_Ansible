import os
import time
from dataclasses import dataclass
from ipaddress import IPv4Address, IPv6Address

from fastapi import FastAPI, HTTPException
from httpx import AsyncClient
from prometheus_client import Counter, Histogram, generate_latest
from sqlalchemy import Column, Integer, String, select
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine
from sqlalchemy.orm import declarative_base

app = FastAPI(title="IP Geolocation API", description="API for IP geolocation with caching")

REQUEST_COUNT = Counter("api_requests_total", "Total API requests", ["method", "endpoint", "status"])
REQUEST_LATENCY = Histogram(
    "api_request_duration_seconds",
    "Request duration in seconds",
    ["method", "endpoint"],
)

DATABASE_URL = f"postgresql+asyncpg://{os.getenv('DB_USER', 'postgres')}:{os.getenv('DB_PASSWORD', 'password')}@{os.getenv('DB_HOST', 'postgres-service')}:{os.getenv('DB_PORT', '5432')}/{os.getenv('DB_NAME', 'ip_geolocation')}"

engine = create_async_engine(DATABASE_URL, echo=False)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)
Base = declarative_base()


@dataclass
class IpData:
    ip: IPv4Address | IPv6Address
    country: str
    cached: bool


class IPRecord(Base):
    __tablename__ = "ip_records"

    id = Column(Integer, primary_key=True, index=True)
    ip = Column(String, unique=True, index=True, nullable=False)
    country = Column(String, nullable=False)


async def fetch_ip_country(ip: IPv4Address | IPv6Address) -> str | None:
    async with AsyncClient() as client:
        response = await client.get(f"http://ip-api.com/json/{ip}?fields=countryCode")
        response.raise_for_status()
        data = response.json()
        return data.get("country_code", None)


async def get_ip_data_from_db(ip: IPv4Address | IPv6Address):
    async with SessionLocal() as session:
        result = await session.execute(select(IPRecord).where(IPRecord.ip == str(ip)))
        record = result.scalar_one_or_none()
        return record.country if record else None


async def save_ip_data_on_db(ip: IPv4Address | IPv6Address, country: str) -> None:
    async with SessionLocal() as session:
        session.add(IPRecord(ip=str(ip), country=country))
        await session.commit()


@app.get("/geolocate/{ip}")
async def get_country(ip: IPv4Address | IPv6Address) -> IpData:
    start_time = time.time()
    REQUEST_COUNT.labels(method="GET", endpoint="/geolocate", status="started").inc()

    try:
        if cached := await get_ip_data_from_db(ip):
            REQUEST_COUNT.labels(method="GET", endpoint="/geolocate", status="success").inc()
            REQUEST_LATENCY.labels(method="GET", endpoint="/geolocate").observe(time.time() - start_time)
            return IpData(ip=ip, country=cached, cached=True)

        result = await fetch_ip_country(ip)
        if result is None:
            REQUEST_COUNT.labels(method="GET", endpoint="/geolocate", status="not_found").inc()
            raise HTTPException(
                status_code=404,
                detail="Country not found for the given IP",
            )

        await save_ip_data_on_db(ip, result)

        REQUEST_COUNT.labels(method="GET", endpoint="/geolocate", status="success").inc()
        REQUEST_LATENCY.labels(method="GET", endpoint="/geolocate").observe(time.time() - start_time)

        return IpData(ip=ip, country=result, cached=False)
    except Exception as e:
        REQUEST_COUNT.labels(method="GET", endpoint="/geolocate", status="error").inc()
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


@app.get("/metrics")
async def metrics():
    return generate_latest()
