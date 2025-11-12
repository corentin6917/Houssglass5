"""Service for detecting life seasons."""
from typing import Dict


def detect_season(metrics_30d: Dict) -> str:
    """
    Detect the user's current life season based on 30-day metrics.

    Seasons:
    - Winter: < 4 grains/day average (struggle, rest)
    - Spring: 4-5 grains/day (growth, renewal)
    - Summer: > 7 grains/day (peak, abundance)
    - Autumn: 5-7 grains/day (harvest, balance)

    Args:
        metrics_30d: Dictionary containing 30-day average metrics

    Returns:
        Season name: 'winter', 'spring', 'summer', or 'autumn'
    """
    avg_grains = metrics_30d.get('avg_grains_per_day', 0)

    if avg_grains < 4.0:
        return 'winter'
    elif avg_grains < 5.0:
        return 'spring'
    elif avg_grains > 7.0:
        return 'summer'
    else:
        return 'autumn'


def get_season_messaging(season: str) -> Dict[str, str]:
    """
    Get appropriate messaging and colors for a season.

    Args:
        season: Season name

    Returns:
        Dictionary with color, message, and encouragement
    """
    messaging = {
        'winter': {
            'color': '#4A90E2',
            'name': 'Winter',
            'message': 'Time for rest and reflection',
            'encouragement': 'Every small step counts. Be gentle with yourself.',
            'emoji': '❄️',
        },
        'spring': {
            'color': '#7CB342',
            'name': 'Spring',
            'message': 'Growth and renewal',
            'encouragement': 'New beginnings are emerging. Keep nurturing your progress.',
            'emoji': '🌱',
        },
        'summer': {
            'color': '#FFD54F',
            'name': 'Summer',
            'message': 'Peak energy and abundance',
            'encouragement': 'You're thriving! Enjoy this momentum.',
            'emoji': '☀️',
        },
        'autumn': {
            'color': '#FF8A65',
            'name': 'Autumn',
            'message': 'Balance and harvest',
            'encouragement': 'Steady progress. Reap what you've sown.',
            'emoji': '🍂',
        },
    }

    return messaging.get(season, messaging['autumn'])
