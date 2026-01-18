"""
Search Indexer Handler

Verarbeitet Entity-Events vom Kernel und aktualisiert den OpenSearch-Index.
"""

import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    EventBridge Event Handler für entity.created, entity.updated, entity.deleted.
    """
    logger.info(f"Received event: {json.dumps(event)}")

    detail_type = event.get("detail-type", "")
    detail = event.get("detail", {})

    entity_id = detail.get("entityId")
    tenant_id = detail.get("tenantId")

    if detail_type == "entity.created":
        return index_entity(tenant_id, entity_id, detail)
    elif detail_type == "entity.updated":
        return update_entity(tenant_id, entity_id, detail)
    elif detail_type == "entity.deleted":
        return delete_entity(tenant_id, entity_id)
    else:
        logger.warning(f"Unknown event type: {detail_type}")
        return {"statusCode": 400, "body": "Unknown event type"}


def index_entity(tenant_id: str, entity_id: str, data: dict) -> dict:
    """Index a new entity."""
    logger.info(f"Indexing entity {entity_id} for tenant {tenant_id}")
    # TODO: OpenSearch indexing logic
    return {"statusCode": 200, "body": f"Indexed {entity_id}"}


def update_entity(tenant_id: str, entity_id: str, data: dict) -> dict:
    """Update an existing entity in the index."""
    logger.info(f"Updating entity {entity_id} for tenant {tenant_id}")
    # TODO: OpenSearch update logic
    return {"statusCode": 200, "body": f"Updated {entity_id}"}


def delete_entity(tenant_id: str, entity_id: str) -> dict:
    """Delete an entity from the index."""
    logger.info(f"Deleting entity {entity_id} for tenant {tenant_id}")
    # TODO: OpenSearch delete logic
    return {"statusCode": 200, "body": f"Deleted {entity_id}"}
