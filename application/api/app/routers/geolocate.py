import time
from ipaddress import IPv4Address, IPv6Address

from fastapi import APIRouter, HTTPException
from prometheus_client import Counter, Histogram

from app.schemas.ip import IpData
from app.services.ip_service import fetch_ip_country, get_ip_data_from_db, save_ip_data_on_db

router = APIRouter()

REQUEST_COUNT = Counter("api_requests_total", "Total API requests", ["method", "endpoint", "status"])
REQUEST_LATENCY = Histogram(
    "api_request_duration_seconds",
    "Request duration in seconds",
    ["method", "endpoint"],
)


@router.get("/geolocate/{ip}")
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
