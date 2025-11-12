"""Database connection and utilities."""
import psycopg2
from psycopg2.extras import RealDictCursor
from contextlib import contextmanager
from .config import get_settings

settings = get_settings()


@contextmanager
def get_db_connection():
    """Context manager for database connections."""
    conn = psycopg2.connect(
        settings.database_url,
        cursor_factory=RealDictCursor,
    )
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def execute_query(query: str, params: dict = None):
    """Execute a query and return results."""
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or {})
            try:
                return cur.fetchall()
            except psycopg2.ProgrammingError:
                # No results to fetch (INSERT, UPDATE, DELETE)
                return None
