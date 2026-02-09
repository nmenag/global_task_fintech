# GlobalTaskFintech

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## System Architecture & Reliability

The system is designed with high reliability and data consistency in mind, following idiomatic Elixir and PostgreSQL patterns:

### 1. Data Consistency & Integrity
- **Transactional Outbox Pattern**: All domain logic and side effects (Audit logs, Risk Engine evaluation, Webhook delivery) are persisted within a single **PostgreSQL Transaction**. This ensures that we never update an application status without also enqueuing the corresponding side effects.
- **Row-Level Locking**: The `TransitionEngine` uses `SELECT ... FOR UPDATE` via `get_for_update/1` to prevent race conditions during concurrent status transitions.
- **Idempotent Job Design**: All background workers (Oban) use **Uniqueness Constraints**. If a job is enqueued multiple times (due to retries or race conditions), Oban ensures only one instance is processed within a specific time window.

### 2. Event-Driven Decoupling
- **Phoenix PubSub**: Domain events are broadcasted over the `domain_events` and `credit_applications` topics.
- **Independent Consumers**: Multiple consumers (LiveView UI, real-time notifications, external integrations) can react to these events independently without coupling the core business logic.

### 3. Horizontal Scalability
The application is ready for horizontal scaling:
- **Stateless App Nodes**: Multiple application instances can run behind a load balancer.
- **Distributed Job Processing**: Oban nodes coordinate via the shared PostgreSQL database. Adding more app nodes naturally increases the processing capacity for background queues like `risk` and `webhooks`.
- **Distributed PubSub**: Uses Phoenix's distributed PubSub (PG2/Horde/Redis) to ensure events broadcasted on one node are received by subscribers on all other nodes.

## Learn more
...
