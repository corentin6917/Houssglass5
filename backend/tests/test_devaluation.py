"""Tests for devaluation logic."""
import pytest
from datetime import datetime, timedelta
from app.services.devaluation import (
    get_devaluation_phase,
    get_phase_multiplier,
    calculate_devalued_grain_value,
)


def test_get_devaluation_phase():
    """Test devaluation phase calculation."""
    current_date = datetime(2025, 1, 12)

    # Phase 1: Days 1-30
    first_use = datetime(2025, 1, 1)  # 11 days ago
    assert get_devaluation_phase(first_use, current_date) == 1

    # Phase 2: Days 31-90
    first_use = datetime(2024, 12, 1)  # 42 days ago
    assert get_devaluation_phase(first_use, current_date) == 2

    # Phase 3: Days 91-180
    first_use = datetime(2024, 10, 1)  # ~103 days ago
    assert get_devaluation_phase(first_use, current_date) == 3

    # Phase 4: Days 181+
    first_use = datetime(2024, 6, 1)  # ~225 days ago
    assert get_devaluation_phase(first_use, current_date) == 4


def test_get_phase_multiplier():
    """Test phase multiplier values."""
    assert get_phase_multiplier(1) == 1.0  # 100%
    assert get_phase_multiplier(2) == 0.8  # 80%
    assert get_phase_multiplier(3) == 0.6  # 60%
    assert get_phase_multiplier(4) == 0.5  # 50%


def test_calculate_devalued_grain_value():
    """Test devalued grain value calculation."""
    base_value = 2.5

    # Phase 1: No devaluation
    assert calculate_devalued_grain_value(base_value, 1) == 2.5

    # Phase 2: 20% reduction
    assert calculate_devalued_grain_value(base_value, 2) == 2.0

    # Phase 3: 40% reduction
    assert calculate_devalued_grain_value(base_value, 3) == 1.5

    # Phase 4: 50% reduction (floor)
    assert calculate_devalued_grain_value(base_value, 4) == 1.25


def test_devaluation_edge_cases():
    """Test edge cases for devaluation."""
    # Same day
    current_date = datetime(2025, 1, 12)
    first_use = datetime(2025, 1, 12)
    assert get_devaluation_phase(first_use, current_date) == 1

    # Exactly 30 days
    first_use = datetime(2024, 12, 13)
    assert get_devaluation_phase(first_use, current_date) == 1

    # Exactly 31 days (should be phase 2)
    first_use = datetime(2024, 12, 12)
    assert get_devaluation_phase(first_use, current_date) == 2
