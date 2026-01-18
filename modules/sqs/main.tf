locals {
  # Pflicht-Tags (CLAUDE.md)
  default_tags = {
    Project     = "mkg"
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "mkg-lib-terraform/sqs"
  }

  tags = merge(local.default_tags, var.additional_tags)

  # Queue-Namen für FIFO
  queue_name = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  dlq_name   = var.fifo_queue ? "${var.queue_name}-dlq.fifo" : "${var.queue_name}-dlq"
}

# Dead Letter Queue (ERZWUNGEN - MKG Security Standards)
resource "aws_sqs_queue" "dlq" {
  name = local.dlq_name

  # FIFO-Konfiguration
  fifo_queue = var.fifo_queue

  # Message Retention für DLQ (länger als Hauptqueue)
  message_retention_seconds = var.dlq_message_retention_seconds

  # SSE-SQS Encryption (ERZWUNGEN - MKG Security Standards)
  sqs_managed_sse_enabled = true

  tags = merge(local.tags, {
    QueueType = "dlq"
  })
}

# Haupt-Queue
resource "aws_sqs_queue" "this" {
  name = local.queue_name

  # FIFO-Konfiguration
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  # Queue-Einstellungen
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # SSE-SQS Encryption (ERZWUNGEN - MKG Security Standards)
  sqs_managed_sse_enabled = true

  # Dead Letter Queue (ERZWUNGEN - MKG Security Standards)
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.dlq_max_receive_count
  })

  tags = merge(local.tags, {
    QueueType = "main"
  })
}

# Redrive Allow Policy für DLQ (erlaubt Nachrichten von Haupt-Queue)
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}
