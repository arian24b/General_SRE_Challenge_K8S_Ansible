from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    db_user: str = "postgres"
    db_password: str = "password"
    db_host: str = "postgres-service"
    db_port: str = "5432"
    db_name: str = "postgres"

    # App
    app_title: str = "IP Geolocation API"
    app_description: str = "API for IP geolocation with caching"
    app_version: str = "1.0.0"
    debug: bool = False

    # Server
    host: str = "0.0.0.0"
    port: int = 8000

    # External API
    ip_api_url: str = "http://ip-api.com/json"

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
