"""Tests for ratio calculation."""
import pytest
from app.services.ratio import calculate_ratio


def test_calculate_ratio_normal():
    """Test normal ratio calculation."""
    # Perfect score: 10 grains per day
    assert calculate_ratio(100.0, 10) == 100.0

    # Good score: 7.5 grains per day average
    assert calculate_ratio(150.0, 20) == 75.0

    # Lower score: 5 grains per day
    assert calculate_ratio(50.0, 10) == 50.0


def test_calculate_ratio_edge_cases():
    """Test edge cases for ratio calculation."""
    # Zero days (new user)
    assert calculate_ratio(0.0, 0) == 0.0

    # Zero grains earned
    assert calculate_ratio(0.0, 10) == 0.0

    # More than 100% (exceptional performance)
    assert calculate_ratio(220.0, 20) == 110.0


def test_calculate_ratio_precision():
    """Test ratio calculation precision."""
    # Should round to 2 decimal places
    ratio = calculate_ratio(77.0, 10)  # 77 / 100 * 100 = 77.0
    assert ratio == 77.0

    # Test rounding
    ratio = calculate_ratio(66.666, 10)
    assert ratio == 66.67


def test_calculate_ratio_realistic_scenarios():
    """Test realistic user scenarios."""
    # User on day 1, earned 8 grains
    assert calculate_ratio(8.0, 1) == 80.0

    # User after 30 days, earned 240 grains (8/day avg)
    assert calculate_ratio(240.0, 30) == 80.0

    # User after 100 days, earned 650 grains (6.5/day avg)
    assert calculate_ratio(650.0, 100) == 65.0

    # Phoenix mode user, getting 3 grains/day
    assert calculate_ratio(30.0, 10) == 30.0
