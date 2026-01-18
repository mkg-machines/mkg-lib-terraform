"""
Search Handler

Führt Suchanfragen gegen den OpenSearch-Index aus.
"""

import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    API Gateway Handler für Suchanfragen.
    """
    logger.info(f"Received request: {json.dumps(event)}")

    # Parse request
    body = json.loads(event.get("body", "{}"))
    query = body.get("query", "")
    filters = body.get("filters", {})
    page = body.get("page", 1)
    page_size = body.get("pageSize", 20)

    # Extract tenant from JWT
    request_context = event.get("requestContext", {})
    authorizer = request_context.get("authorizer", {})
    jwt = authorizer.get("jwt", {})
    claims = jwt.get("claims", {})
    tenant_id = claims.get("custom:tenant_id")

    if not tenant_id:
        return {
            "statusCode": 401,
            "body": json.dumps({"error": "Missing tenant_id in token"})
        }

    # Execute search
    results = search_entities(tenant_id, query, filters, page, page_size)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(results)
    }


def search_entities(
    tenant_id: str,
    query: str,
    filters: dict,
    page: int,
    page_size: int
) -> dict:
    """Execute search against OpenSearch."""
    logger.info(f"Searching for '{query}' in tenant {tenant_id}")

    # TODO: OpenSearch query logic
    return {
        "items": [],
        "total": 0,
        "page": page,
        "pageSize": page_size,
        "query": query,
        "filters": filters
    }
