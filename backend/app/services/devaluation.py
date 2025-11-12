"""Service for goal devaluation logic."""
from datetime import datetime, timedelta


def get_devaluation_phase(first_use_date: datetime, current_date: datetime) -> int:
    """
    Determine the devaluation phase based on how long the goal has been repeated.

    Phases:
    - Phase 1 (Days 1-30): 100% value
    - Phase 2 (Days 31-90): 80% value (-20%)
    - Phase 3 (Days 91-180): 60% value (-40%)
    - Phase 4 (Days 181+): 50% value (-50%, floor)

    Args:
        first_use_date: When the goal was first used
        current_date: Current date

    Returns:
        Phase number (1-4)
    """
    days_used = (current_date - first_use_date).days

    if days_used <= 30:
        return 1
    elif days_used <= 90:
        return 2
    elif days_used <= 180:
        return 3
    else:
        return 4


def get_phase_multiplier(phase: int) -> float:
    """
    Get the value multiplier for a given phase.

    Args:
        phase: Phase number (1-4)

    Returns:
        Multiplier (1.0, 0.8, 0.6, 0.5)
    """
    multipliers = {
        1: 1.0,   # 100%
        2: 0.8,   # 80%
        3: 0.6,   # 60%
        4: 0.5,   # 50%
    }
    return multipliers.get(phase, 0.5)


def calculate_devalued_grain_value(base_value: float, phase: int) -> float:
    """
    Calculate the actual grain value after applying devaluation.

    Args:
        base_value: Original grain value for the goal
        phase: Devaluation phase (1-4)

    Returns:
        Devalued grain value
    """
    multiplier = get_phase_multiplier(phase)
    return round(base_value * multiplier, 2)
