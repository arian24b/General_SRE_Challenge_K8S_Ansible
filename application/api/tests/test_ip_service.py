import pytest
from ipaddress import IPv4Address
from unittest.mock import AsyncMock, patch, Mock

from app.services.ip_service import fetch_ip_country, get_ip_data_from_db, save_ip_data_on_db


@pytest.mark.asyncio
async def test_fetch_ip_country_success():
    ip = IPv4Address("8.8.8.8")
    with patch("app.services.ip_service.AsyncClient") as mock_client:
        mock_response = Mock()
        mock_response.json.return_value = {"countryCode": "US"}
        mock_response.raise_for_status.return_value = None
        mock_client.return_value.__aenter__.return_value.get.return_value = mock_response

        result = await fetch_ip_country(ip)
        assert result == "US"


@pytest.mark.asyncio
async def test_fetch_ip_country_no_country():
    ip = IPv4Address("8.8.8.8")
    with patch("app.services.ip_service.AsyncClient") as mock_client:
        mock_response = Mock()
        mock_response.json.return_value = {}
        mock_response.raise_for_status.return_value = None
        mock_client.return_value.__aenter__.return_value.get.return_value = mock_response

        result = await fetch_ip_country(ip)
        assert result is None


@pytest.mark.asyncio
async def test_get_ip_data_from_db_found():
    ip = IPv4Address("8.8.8.8")
    with patch("app.services.ip_service.SessionLocal") as mock_session:
        mock_record = Mock()
        mock_record.country = "US"
        mock_result = Mock()
        mock_result.scalar_one_or_none.return_value = mock_record
        mock_session.return_value.__aenter__.return_value.execute.return_value = mock_result

        result = await get_ip_data_from_db(ip)
        assert result == "US"


@pytest.mark.asyncio
async def test_get_ip_data_from_db_not_found():
    ip = IPv4Address("8.8.8.8")
    with patch("app.services.ip_service.SessionLocal") as mock_session:
        mock_result = Mock()
        mock_result.scalar_one_or_none.return_value = None
        mock_session.return_value.__aenter__.return_value.execute.return_value = mock_result

        result = await get_ip_data_from_db(ip)
        assert result is None


@pytest.mark.asyncio
async def test_save_ip_data_on_db():
    ip = IPv4Address("8.8.8.8")
    country = "US"
    with patch("app.services.ip_service.SessionLocal") as mock_session:
        mock_session_instance = AsyncMock()
        mock_session.return_value.__aenter__.return_value = mock_session_instance

        await save_ip_data_on_db(ip, country)
        mock_session_instance.add.assert_called_once()
        mock_session_instance.commit.assert_called_once()
