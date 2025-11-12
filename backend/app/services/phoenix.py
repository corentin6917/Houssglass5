"""Service for Phoenix Mode detection and management."""
from datetime import datetime, timedelta
from typing import Dict, Optional


def should_activate_phoenix_mode(user_metrics: Dict) -> tuple[bool, str]:
    """
    Determine if Phoenix Mode should be activated for a user.

    Triggers:
    1. < 3 grains/day for 14 consecutive days
    2. Ratio drops by 10%+ in one month
    3. No victories for 14 consecutive days

    Args:
        user_metrics: Dictionary containing user statistics

    Returns:
        Tuple of (should_activate, reason)
    """
    # Trigger 1: Low grains for extended period
    avg_grains_14d = user_metrics.get('avg_grains_last_14_days', 0)
    if avg_grains_14d < 3.0:
        return True, "Low grain average (<3) for 14 days"

    # Trigger 2: Significant ratio drop
    ratio_change_30d = user_metrics.get('ratio_change_last_30_days', 0)
    if ratio_change_30d <= -10.0:
        return True, f"Ratio dropped by {abs(ratio_change_30d):.1f}% in 30 days"

    # Trigger 3: No victories
    days_without_victory = user_metrics.get('days_without_victory', 0)
    if days_without_victory >= 14:
        return True, f"No victories for {days_without_victory} days"

    return False, ""


def apply_phoenix_multiplier(base_value: float, is_micro_victory: bool = False) -> float:
    """
    Apply Phoenix Mode multiplier to grain values.

    Phoenix Mode benefits:
    - Micro-victories get 3x multiplier
    - Minimum 1 grain per day guaranteed

    Args:
        base_value: Original grain value
        is_micro_victory: Whether this is classified as a micro-victory

    Returns:
        Modified grain value
    """
    if is_micro_victory:
        return round(base_value * 3.0, 2)
    return base_value


def classify_as_micro_victory(goal_title: str) -> bool:
    """
    Determine if a goal qualifies as a micro-victory.

    Micro-victories are small, achievable actions that demonstrate
    engagement even during difficult periods.

    Args:
        goal_title: The goal description

    Returns:
        True if this is a micro-victory
    """
    micro_keywords = [
        'shower', 'bath', 'brush', 'teeth',
        'bed', 'sleep', 'wake',
        'eat', 'meal', 'breakfast', 'lunch', 'dinner',
        'water', 'hydrate',
        'walk', 'step',
        'call', 'text', 'message',
        'breathe', 'breath',
        '5 min', '10 min', 'minute',
    ]

    goal_lower = goal_title.lower()
    return any(keyword in goal_lower for keyword in micro_keywords)


def get_phoenix_minimum_grains() -> int:
    """Return the minimum grains guaranteed in Phoenix Mode."""
    return 1
