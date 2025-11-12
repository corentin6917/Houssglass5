"""Service for calculating user ratio."""


def calculate_ratio(total_grains: float, days_on_app: int) -> float:
    """
    Calculate user's life ratio.

    Formula: (total_grains / (days_on_app × 10)) × 100

    Args:
        total_grains: Total accumulated grains
        days_on_app: Number of days since user joined

    Returns:
        Ratio as a percentage (0-100+)
    """
    if days_on_app == 0:
        return 0.0

    max_possible_grains = days_on_app * 10
    ratio = (total_grains / max_possible_grains) * 100

    return round(ratio, 2)
