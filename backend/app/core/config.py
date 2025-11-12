"""Configuration management for the backend."""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""

    # Supabase
    supabase_url: str
    supabase_key: str
    supabase_jwt_secret: str

    # Database
    database_url: str

    # App
    app_env: str = "development"
    api_host: str = "0.0.0.0"
    api_port: int = 8000

    # Constants
    daily_grains_potential: int = 10
    boost_cost: float = 0.2
    transfusion_amount: float = 1.0
    comment_cost: float = 0.1

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
