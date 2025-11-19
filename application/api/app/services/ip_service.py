from ipaddress import IPv4Address, IPv6Address
from httpx import AsyncClient
from sqlalchemy import select

from app.core.config import settings
from app.db.database import SessionLocal
from app.models.ip import IPRecord


async def fetch_ip_country(ip: IPv4Address | IPv6Address) -> str | None:
    async with AsyncClient() as client:
        response = await client.get(f"{settings.ip_api_url}/{ip}?fields=countryCode")
        response.raise_for_status()
        data = response.json()
        return data.get("countryCode", None)


async def get_ip_data_from_db(ip: IPv4Address | IPv6Address):
    async with SessionLocal() as session:
        result = await session.execute(select(IPRecord).where(IPRecord.ip == str(ip)))
        record = result.scalar_one_or_none()
        return record.country if record else None


async def save_ip_data_on_db(ip: IPv4Address | IPv6Address, country: str) -> None:
    async with SessionLocal() as session:
        session.add(IPRecord(ip=str(ip), country=country))
        await session.commit()
