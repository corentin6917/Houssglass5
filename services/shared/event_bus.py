"""
Central Event Bus using Kafka
Handles all event-driven communication between microservices
"""
import json
import asyncio
from typing import Callable, Dict, Any, List
from datetime import datetime
from enum import Enum
from kafka import KafkaProducer, KafkaConsumer
from kafka.errors import KafkaError
import logging

logger = logging.getLogger(__name__)


class EventType(str, Enum):
    """All possible event types in the system"""
    # User Events
    USER_CREATED = "user.created"
    USER_UPDATED = "user.updated"
    USER_DELETED = "user.deleted"
    USER_LOGGED_IN = "user.logged_in"

    # Goal Events
    GOAL_CREATED = "goal.created"
    GOAL_COMPLETED = "goal.completed"
    GOAL_FAILED = "goal.failed"
    GOAL_UPDATED = "goal.updated"
    GOAL_DELETED = "goal.deleted"

    # Grain Events
    GRAIN_EARNED = "grain.earned"
    GRAIN_EVAPORATED = "grain.evaporated"
    GRAIN_TRANSFERRED = "grain.transferred"

    # Contract Events
    CONTRACT_CREATED = "contract.created"
    CONTRACT_SYNCED = "contract.synced"
    CONTRACT_EXPIRED = "contract.expired"

    # Gamification Events
    LEVEL_UP = "user.level_up"
    XP_GAINED = "user.xp_gained"
    ACHIEVEMENT_UNLOCKED = "achievement.unlocked"
    ACHIEVEMENT_PROGRESS = "achievement.progress"

    # Phoenix Events
    PHOENIX_ENTERED = "phoenix.entered"
    PHOENIX_EXITED = "phoenix.exited"
    PHOENIX_PROGRESS = "phoenix.progress"

    # Season Events
    SEASON_CHANGED = "season.changed"
    SEASON_MILESTONE = "season.milestone"

    # Social Events
    BOOST_SENT = "social.boost_sent"
    BOOST_RECEIVED = "social.boost_received"
    TRANSFUSION_SENT = "social.transfusion_sent"
    TRANSFUSION_RECEIVED = "social.transfusion_received"
    COMMENT_POSTED = "social.comment_posted"
    COMMENT_RECEIVED = "social.comment_received"

    # Feed Events
    FEED_ITEM_CREATED = "feed.item_created"
    FEED_ITEM_EXPIRED = "feed.item_expired"
    FEED_ITEM_INTERACTED = "feed.item_interacted"

    # Challenge Events
    CHALLENGE_CREATED = "challenge.created"
    CHALLENGE_JOINED = "challenge.joined"
    CHALLENGE_COMPLETED = "challenge.completed"
    CHALLENGE_FAILED = "challenge.failed"
    CHALLENGE_PROGRESS = "challenge.progress"

    # Notification Events
    NOTIFICATION_SEND = "notification.send"
    NOTIFICATION_DELIVERED = "notification.delivered"
    NOTIFICATION_OPENED = "notification.opened"

    # Analytics Events
    PAGE_VIEW = "analytics.page_view"
    ACTION_TRACKED = "analytics.action_tracked"
    ERROR_OCCURRED = "analytics.error_occurred"


class Event:
    """Base event class"""
    def __init__(
        self,
        event_type: EventType,
        payload: Dict[str, Any],
        user_id: str = None,
        correlation_id: str = None,
        metadata: Dict[str, Any] = None
    ):
        self.event_type = event_type
        self.payload = payload
        self.user_id = user_id
        self.correlation_id = correlation_id
        self.metadata = metadata or {}
        self.timestamp = datetime.utcnow().isoformat()
        self.version = "1.0"

    def to_dict(self) -> Dict[str, Any]:
        return {
            "event_type": self.event_type.value,
            "payload": self.payload,
            "user_id": self.user_id,
            "correlation_id": self.correlation_id,
            "metadata": self.metadata,
            "timestamp": self.timestamp,
            "version": self.version
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Event':
        return cls(
            event_type=EventType(data["event_type"]),
            payload=data["payload"],
            user_id=data.get("user_id"),
            correlation_id=data.get("correlation_id"),
            metadata=data.get("metadata", {})
        )


class EventBus:
    """
    Central Event Bus for event-driven architecture
    Uses Kafka as the underlying message broker
    """
    def __init__(self, bootstrap_servers: List[str], client_id: str = "hourglass"):
        self.bootstrap_servers = bootstrap_servers
        self.client_id = client_id

        # Producer for publishing events
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            client_id=f"{client_id}-producer",
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            acks='all',  # Wait for all replicas
            retries=3,
            max_in_flight_requests_per_connection=1  # Ensure ordering
        )

        # Consumers registry
        self.consumers: Dict[EventType, List[Callable]] = {}
        self.consumer_tasks: List[asyncio.Task] = []

        logger.info(f"EventBus initialized with brokers: {bootstrap_servers}")

    async def publish(
        self,
        event_type: EventType,
        payload: Dict[str, Any],
        user_id: str = None,
        correlation_id: str = None,
        metadata: Dict[str, Any] = None
    ) -> bool:
        """
        Publish an event to the event bus

        Args:
            event_type: Type of event
            payload: Event data
            user_id: Optional user ID
            correlation_id: Optional correlation ID for tracking
            metadata: Optional metadata

        Returns:
            bool: True if published successfully
        """
        event = Event(
            event_type=event_type,
            payload=payload,
            user_id=user_id,
            correlation_id=correlation_id,
            metadata=metadata
        )

        try:
            # Send to Kafka topic
            topic = f"hourglass.{event_type.value}"
            future = self.producer.send(topic, event.to_dict())

            # Wait for confirmation
            record_metadata = future.get(timeout=10)

            logger.info(
                f"Published event {event_type.value} to "
                f"topic {topic} partition {record_metadata.partition} "
                f"offset {record_metadata.offset}"
            )

            return True

        except KafkaError as e:
            logger.error(f"Failed to publish event {event_type.value}: {e}")
            return False

    def subscribe(
        self,
        event_type: EventType,
        handler: Callable[[Event], None],
        group_id: str = None
    ):
        """
        Subscribe to an event type

        Args:
            event_type: Type of event to subscribe to
            handler: Async function to handle the event
            group_id: Consumer group ID (for load balancing)
        """
        if event_type not in self.consumers:
            self.consumers[event_type] = []

        self.consumers[event_type].append(handler)

        # Start consumer task
        task = asyncio.create_task(
            self._consume_events(event_type, handler, group_id)
        )
        self.consumer_tasks.append(task)

        logger.info(f"Subscribed to {event_type.value} with handler {handler.__name__}")

    async def _consume_events(
        self,
        event_type: EventType,
        handler: Callable,
        group_id: str = None
    ):
        """Internal method to consume events from Kafka"""
        topic = f"hourglass.{event_type.value}"
        group = group_id or f"{self.client_id}-{event_type.value}-group"

        consumer = KafkaConsumer(
            topic,
            bootstrap_servers=self.bootstrap_servers,
            group_id=group,
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            auto_offset_reset='latest',
            enable_auto_commit=True
        )

        logger.info(f"Started consuming from {topic} with group {group}")

        try:
            for message in consumer:
                event_data = message.value
                event = Event.from_dict(event_data)

                try:
                    # Call handler
                    if asyncio.iscoroutinefunction(handler):
                        await handler(event)
                    else:
                        handler(event)

                    logger.debug(f"Handled event {event_type.value}")

                except Exception as e:
                    logger.error(
                        f"Error handling event {event_type.value}: {e}",
                        exc_info=True
                    )

        except Exception as e:
            logger.error(f"Consumer error for {topic}: {e}", exc_info=True)

        finally:
            consumer.close()

    def close(self):
        """Close all connections"""
        logger.info("Closing EventBus...")

        # Cancel all consumer tasks
        for task in self.consumer_tasks:
            task.cancel()

        # Close producer
        self.producer.close()

        logger.info("EventBus closed")


# Singleton instance
_event_bus: EventBus = None


def get_event_bus(
    bootstrap_servers: List[str] = None,
    client_id: str = "hourglass"
) -> EventBus:
    """Get or create the event bus singleton"""
    global _event_bus

    if _event_bus is None:
        if bootstrap_servers is None:
            bootstrap_servers = ["localhost:9092"]

        _event_bus = EventBus(bootstrap_servers, client_id)

    return _event_bus


# Convenience decorators for subscribing to events
def on_event(event_type: EventType, group_id: str = None):
    """
    Decorator to subscribe a function to an event

    Usage:
        @on_event(EventType.GOAL_COMPLETED)
        async def handle_goal_completed(event: Event):
            print(f"Goal completed: {event.payload}")
    """
    def decorator(func: Callable):
        event_bus = get_event_bus()
        event_bus.subscribe(event_type, func, group_id)
        return func
    return decorator


# Example usage and event handlers
if __name__ == "__main__":
    import asyncio

    # Example: Publishing events
    async def example_publish():
        event_bus = get_event_bus()

        # Publish goal completed event
        await event_bus.publish(
            EventType.GOAL_COMPLETED,
            payload={
                "goal_id": "goal_123",
                "goal_title": "Morning run",
                "grains_earned": 2.5
            },
            user_id="user_456",
            correlation_id="correlation_789"
        )

    # Example: Subscribing to events
    @on_event(EventType.GOAL_COMPLETED)
    async def handle_goal_completed(event: Event):
        """Handle goal completion"""
        print(f"🎯 Goal completed!")
        print(f"   User: {event.user_id}")
        print(f"   Goal: {event.payload['goal_title']}")
        print(f"   Grains: {event.payload['grains_earned']}")

        # Trigger side effects
        await asyncio.gather(
            update_user_stats(event.user_id),
            check_achievements(event.user_id),
            update_leaderboard(event.user_id)
        )

    @on_event(EventType.LEVEL_UP)
    async def handle_level_up(event: Event):
        """Handle level up"""
        print(f"🎊 Level up!")
        print(f"   User: {event.user_id}")
        print(f"   New Level: {event.payload['new_level']}")

        # Send notification
        await send_notification(
            event.user_id,
            f"Félicitations ! Tu as atteint le niveau {event.payload['new_level']}!"
        )

    async def update_user_stats(user_id: str):
        print(f"Updating stats for {user_id}")
        await asyncio.sleep(0.1)

    async def check_achievements(user_id: str):
        print(f"Checking achievements for {user_id}")
        await asyncio.sleep(0.1)

    async def update_leaderboard(user_id: str):
        print(f"Updating leaderboard for {user_id}")
        await asyncio.sleep(0.1)

    async def send_notification(user_id: str, message: str):
        print(f"Sending notification to {user_id}: {message}")
        await asyncio.sleep(0.1)

    # Run example
    async def main():
        await example_publish()
        await asyncio.sleep(5)  # Wait for consumers to process

    asyncio.run(main())
