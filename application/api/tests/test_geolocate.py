import pytest
from ipaddress import IPv4Address
from unittest.mock import patch

from app.routers.geolocate import get_country


@pytest.mark.asyncio
async def test_get_country_cached():
    ip = IPv4Address("8.8.8.8")
    with patch("app.routers.geolocate.get_ip_data_from_db", return_value="US") as mock_get:
        result = await get_country(ip)
        assert result.ip == ip
        assert result.country == "US"
        assert result.cached is True
        mock_get.assert_called_once_with(ip)


@pytest.mark.asyncio
async def test_get_country_fetched():
    ip = IPv4Address("8.8.8.8")
    with (
        patch("app.routers.geolocate.get_ip_data_from_db", return_value=None) as mock_get,
        patch("app.routers.geolocate.fetch_ip_country", return_value="US") as mock_fetch,
        patch("app.routers.geolocate.save_ip_data_on_db") as mock_save,
    ):
        result = await get_country(ip)
        assert result.ip == ip
        assert result.country == "US"
        assert result.cached is False
        mock_get.assert_called_once_with(ip)
        mock_fetch.assert_called_once_with(ip)
        mock_save.assert_called_once_with(ip, "US")


@pytest.mark.asyncio
async def test_get_country_not_found():
    ip = IPv4Address("8.8.8.8")
    with (
        patch("app.routers.geolocate.get_ip_data_from_db", return_value=None),
        patch("app.routers.geolocate.fetch_ip_country", return_value=None),
    ):
        with pytest.raises(Exception):  # HTTPException
            await get_country(ip)
