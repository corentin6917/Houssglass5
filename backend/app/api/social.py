"""API endpoints for social interactions."""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..core.auth import get_current_user_id
from ..core.db import execute_query

router = APIRouter(prefix="/api/social", tags=["social"])


class BoostRequest(BaseModel):
    feed_item_id: str
    to_user_id: str


class TransfusionRequest(BaseModel):
    to_user_id: str
    amount: float = 1.0


class CommentRequest(BaseModel):
    feed_item_id: str
    text: str


@router.post("/boost")
async def send_boost(
    request: BoostRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Send an Éclat de Grain (boost) to another user.

    Cost: 0.2 grains from sender's daily reserve
    Benefit: +0.2 grains to receiver
    """
    BOOST_COST = 0.2

    # Check sender has enough grains today
    # (In production: query today's available grains)

    # Deduct from sender
    execute_query(
        """
        INSERT INTO grains_ledger (user_id, type, amount, ref_id)
        VALUES (%(user_id)s, 'boost_out', %(amount)s, %(ref_id)s)
        """,
        {"user_id": user_id, "amount": -BOOST_COST, "ref_id": request.feed_item_id},
    )

    # Credit to receiver
    execute_query(
        """
        INSERT INTO grains_ledger (user_id, type, amount, ref_id)
        VALUES (%(user_id)s, 'boost_in', %(amount)s, %(ref_id)s)
        """,
        {"user_id": request.to_user_id, "amount": BOOST_COST, "ref_id": request.feed_item_id},
    )

    # Record boost
    execute_query(
        """
        INSERT INTO boosts (from_user, to_user, amount, feed_item_id)
        VALUES (%(from_user)s, %(to_user)s, %(amount)s, %(feed_item_id)s)
        """,
        {
            "from_user": user_id,
            "to_user": request.to_user_id,
            "amount": BOOST_COST,
            "feed_item_id": request.feed_item_id,
        },
    )

    return {"success": True, "cost": BOOST_COST}


@router.post("/transfusion")
async def send_transfusion(
    request: TransfusionRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Send a Transfusion to another user.

    Cost: 1 grain from sender's heritage (accumulated grains)
    Benefit: +1 grain to receiver's heritage
    """
    TRANSFUSION_AMOUNT = 1.0

    # Check sender has enough heritage grains
    # (In production: verify heritage balance)

    # Deduct from sender's heritage
    execute_query(
        """
        INSERT INTO grains_ledger (user_id, type, amount, ref_id)
        VALUES (%(user_id)s, 'transfusion_out', %(amount)s, NULL)
        """,
        {"user_id": user_id, "amount": -TRANSFUSION_AMOUNT},
    )

    # Credit to receiver's heritage
    execute_query(
        """
        INSERT INTO grains_ledger (user_id, type, amount, ref_id)
        VALUES (%(user_id)s, 'transfusion_in', %(amount)s, NULL)
        """,
        {"user_id": request.to_user_id, "amount": TRANSFUSION_AMOUNT},
    )

    # Record transfusion
    execute_query(
        """
        INSERT INTO transfusions (from_user, to_user, amount)
        VALUES (%(from_user)s, %(to_user)s, %(amount)s)
        """,
        {
            "from_user": user_id,
            "to_user": request.to_user_id,
            "amount": TRANSFUSION_AMOUNT,
        },
    )

    return {"success": True, "amount": TRANSFUSION_AMOUNT}


@router.post("/comment")
async def post_comment(
    request: CommentRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Post a comment on a feed item.

    Cost: 0.1 grains (encourages quality comments)
    """
    COMMENT_COST = 0.1

    # Deduct cost
    execute_query(
        """
        INSERT INTO grains_ledger (user_id, type, amount, ref_id)
        VALUES (%(user_id)s, 'comment_cost', %(amount)s, %(ref_id)s)
        """,
        {"user_id": user_id, "amount": -COMMENT_COST, "ref_id": request.feed_item_id},
    )

    # Create comment
    execute_query(
        """
        INSERT INTO comments (user_id, feed_item_id, text, cost)
        VALUES (%(user_id)s, %(feed_item_id)s, %(text)s, %(cost)s)
        """,
        {
            "user_id": user_id,
            "feed_item_id": request.feed_item_id,
            "text": request.text,
            "cost": COMMENT_COST,
        },
    )

    return {"success": True, "cost": COMMENT_COST}
