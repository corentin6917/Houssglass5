"""API endpoints for goal management."""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List
from datetime import datetime

from ..core.auth import get_current_user_id
from ..services.auto_valuation import auto_evaluate_goal, distribute_grains_across_goals
from ..services.devaluation import get_devaluation_phase, calculate_devalued_grain_value

router = APIRouter(prefix="/api/goals", tags=["goals"])


class GoalCreate(BaseModel):
    title: str


class GoalEvaluateRequest(BaseModel):
    goals: List[str]


class GoalEvaluateResponse(BaseModel):
    evaluations: List[dict]


@router.post("/evaluate", response_model=GoalEvaluateResponse)
async def evaluate_goals(
    request: GoalEvaluateRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Evaluate goals and assign grain values.

    This endpoint:
    1. Auto-evaluates each goal using keyword matching
    2. Distributes the 10 daily grains across goals
    3. Returns the assigned values (before devaluation)

    Devaluation is applied later based on goal history.
    """
    if not request.goals or len(request.goals) > 3:
        raise HTTPException(status_code=400, detail="Must provide 1-3 goals")

    # Distribute grains across goals
    distribution = distribute_grains_across_goals(request.goals, total_available=10)

    evaluations = [
        {
            "title": goal,
            "base_value": value,
            "explanation": f"Auto-evaluated based on activity type",
        }
        for goal, value in distribution.items()
    ]

    return GoalEvaluateResponse(evaluations=evaluations)


@router.post("/devaluate")
async def calculate_devaluation(
    goal_id: str,
    first_use_date: datetime,
    base_value: float,
    user_id: str = Depends(get_current_user_id),
):
    """
    Calculate the devalued grain value for a repeated goal.

    Args:
        goal_id: Goal identifier
        first_use_date: When the goal was first used
        base_value: Original grain value

    Returns:
        Devalued grain value and phase information
    """
    current_date = datetime.now()
    phase = get_devaluation_phase(first_use_date, current_date)
    devalued_value = calculate_devalued_grain_value(base_value, phase)

    days_used = (current_date - first_use_date).days

    return {
        "goal_id": goal_id,
        "base_value": base_value,
        "devalued_value": devalued_value,
        "phase": phase,
        "days_used": days_used,
        "reduction_percent": round((1 - devalued_value / base_value) * 100, 1),
    }
