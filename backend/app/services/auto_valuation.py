"""Service for automatic goal valuation."""
import re
from typing import Dict


# Simple keyword-based valuation mapping
GOAL_KEYWORDS = {
    # Physical activities (higher value)
    'run': 2.5, 'running': 2.5, 'jog': 2.0, 'jogging': 2.0,
    'workout': 2.5, 'exercise': 2.5, 'gym': 2.5,
    'swim': 2.5, 'swimming': 2.5,
    'bike': 2.0, 'cycling': 2.0,
    'walk': 1.5, 'walking': 1.5,
    'yoga': 2.0, 'stretch': 1.5,

    # Mental/Creative activities
    'read': 2.0, 'reading': 2.0, 'book': 2.0,
    'write': 2.0, 'writing': 2.0,
    'meditate': 2.5, 'meditation': 2.5,
    'learn': 2.0, 'study': 2.0,
    'practice': 2.0,

    # Social/Emotional
    'call': 1.5, 'phone': 1.5,
    'meet': 2.0, 'visit': 2.0,
    'help': 2.5, 'volunteer': 3.0,

    # Work/Productivity
    'project': 2.0, 'work': 1.5,
    'complete': 2.0, 'finish': 2.0,
    'organize': 1.5, 'clean': 1.5,

    # Health
    'cook': 1.5, 'meal': 1.5,
    'water': 1.0, 'hydrate': 1.0,
    'sleep': 1.5,
    'doctor': 2.0, 'appointment': 1.5,
}

DEFAULT_VALUE = 1.5  # Default if no keywords match


def auto_evaluate_goal(goal_title: str, user_context: Dict = None) -> float:
    """
    Automatically evaluate a goal and assign a base grain value.

    Uses keyword matching and simple heuristics. In production, this could
    be enhanced with ML/LLM.

    Args:
        goal_title: The goal description
        user_context: Optional user context for personalization

    Returns:
        Base grain value (before devaluation)
    """
    goal_lower = goal_title.lower()

    # Find matching keywords
    matched_values = []
    for keyword, value in GOAL_KEYWORDS.items():
        if re.search(r'\b' + keyword + r'\b', goal_lower):
            matched_values.append(value)

    if matched_values:
        # Use the highest matching value
        base_value = max(matched_values)
    else:
        base_value = DEFAULT_VALUE

    # Adjust based on length/complexity (longer goals might be more complex)
    word_count = len(goal_title.split())
    if word_count > 5:
        base_value += 0.5

    # Cap at reasonable maximum
    base_value = min(base_value, 4.0)

    return round(base_value, 2)


def distribute_grains_across_goals(goals: list, total_available: int = 10) -> Dict[str, float]:
    """
    Distribute the daily 10 grains across multiple goals.

    Args:
        goals: List of goal titles
        total_available: Total grains available (default 10)

    Returns:
        Dictionary mapping goal titles to grain values
    """
    if not goals:
        return {}

    # Get base values for each goal
    base_values = {goal: auto_evaluate_goal(goal) for goal in goals}
    total_base = sum(base_values.values())

    # Normalize to sum to 10 grains
    if total_base > 0:
        distribution = {
            goal: round((value / total_base) * total_available, 2)
            for goal, value in base_values.items()
        }
    else:
        # Equal distribution if all fail
        per_goal = round(total_available / len(goals), 2)
        distribution = {goal: per_goal for goal in goals}

    # Ensure we don't exceed 10 due to rounding
    actual_total = sum(distribution.values())
    if actual_total > total_available:
        # Adjust the largest value
        largest_goal = max(distribution, key=distribution.get)
        distribution[largest_goal] -= (actual_total - total_available)
        distribution[largest_goal] = round(distribution[largest_goal], 2)

    return distribution
