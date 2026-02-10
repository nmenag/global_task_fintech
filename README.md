# GlobalTaskFintech

A robust, event-driven FinTech application for managing global credit application workflows with country-specific business rules.

## 🏗️ Architecture Overview

The system is built on **Hexagonal Architecture** principles, ensuring a clean separation between domain logic and infrastructure. It leverages the **Transactional Outbox Pattern** to guarantee consistency between state changes and background side effects.

### System Components
```mermaid
graph TD
    User([User/API Client]) <--> LB[Load Balancer]
    LB <--> Web[Web Service <br/>Phoenix + LiveView]

    subgraph "Application Cluster"
        Web <--> Cluster[Distributed <br/>Erlang Cluster]
        Worker[Worker Service <br/>Oban Background Jobs] <--> Cluster
    end

    Web <--> DB[(PostgreSQL)]
    Worker <--> DB

    Web --> GoRules[GoRules Engine <br/>Decision Automation]
    Worker --> GoRules
    Worker --> Webhooks[External Partners <br/>Status Webhooks]
```

### Core Domain Lifecycle
```mermaid
sequenceDiagram
    participant U as Client
    participant API as Phoenix / LiveView
    participant TE as TransitionEngine
    participant DB as PostgreSQL (TX)
    participant O as Oban (Job Queue)

    U->>API: Submit Application
    API->>TE: trigger_transition(app, :evaluate)

    Note over TE, DB: Begin DB Transaction
    TE->>DB: Lock Row & Update Status
    TE->>DB: Insert Audit Log
    TE->>DB: Enqueue Risk Check Job (Outbox)
    DB-->>TE: COMMIT

    TE-->>API: :ok
    API-->>U: Response (Pending)

    Note over O: Background Processing
    O->>GoRules: Fetch Decision Logic
    O->>TE: finalize_status(:approved | :rejected)
    O->>Webhooks: Notify External Systems
```

---

## 🧠 Business Rules Engine (GoRules)

This project leverages **[GoRules Zen Engine](https://gorules.io/)** to manage complex decision-making logic outside of the core application code.

- **Dynamic Evaluation**: Decisions such as risk scoring, eligibility checks, and country-specific field requirements are handled by GoRules.
- **Rule Management**: Business rules are defined as decision tables/trees in the `gorules/rules/` directory.
- **Seamless Integration**: The `BusinessRulesClient` provides an idiomatic Elixir interface to evaluate these rules via a lightweight JSON API.

---

## 🚀 Getting Started

### 1. Local Development (Mix)
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/global_task_fintech.git
   cd global_task_fintech
   ```
2. Setup environment variables:
   ```bash
   cp .env.example .env
   # Update .env with your local credentials
   ```
3. Install dependencies and setup database:
   ```bash
   mix setup
   ```
4. Start the server:
   ```bash
   mix phx.server
   ```

### 2. Docker Compose
Start the entire stack (App, DB, GoRules):
```bash
docker compose build
docker compose up -d
```
Access at `http://localhost:4000`.

### 3. Kubernetes (Local Testing with Kind)
1. Apply manifests:
   ```bash
   kubectl apply -f k8s/
   ```
2. Run migrations:
   ```bash
   kubectl apply -f k8s/migration-job.yaml
   ```
3. Port-forward:
   ```bash
   kubectl port-forward svc/app-service 4000:4000 -n global-task-fintech
   ```

---

## 🛠️ Reliability Features

### 1. Data Consistency & Integrity
- **Transactional Outbox Pattern**: All domain logic and side effects (Audit logs, Risk Engine evaluation, Webhook delivery) are persisted within a single **PostgreSQL Transaction**.
- **Row-Level Locking**: The `TransitionEngine` uses `SELECT ... FOR UPDATE` to prevent race conditions during concurrent status transitions.
- **Idempotent Job Design**: Background workers (Oban) use **Uniqueness Constraints** to ensure jobs aren't processed multiple times.

### 2. Security & Compliance
- **PII Encryption**: Sensitive data like `document_number` is encrypted using **Cloak.Ecto** (AES.GCM) with keys managed via environment variables.
- **Auditability**: Every state change is recorded in an `audit_logs` table within the same transaction.

### 3. Horizontal Scalability
- **Distributed PubSub**: Real-time UI updates (LiveView) work across nodes using Phoenix.PubSub.
- **Distributed Erlang**: Pods can form a cluster for state sharing and distributed task execution.

---

## 🔌 API Documentation

All API requests expect `Content-Type: application/json` and return JSON responses.

### 1. Authentication
**POST** `/api/v1/login`

Returns a JWT token required for all other endpoints (except webhooks).

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response:** `200 OK`
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "email": "user@example.com", "role": "admin" }
}
```

---

### 2. Credit Applications
All endpoints require `Authorization: Bearer <token>`. Write operations (`POST`, `PUT`, `DELETE`) require **admin** role.

#### **GET** `/api/v1/credit-applications`
List all applications. Supports filtering (e.g., `?status=pending`).

#### **GET** `/api/v1/credit-applications/:id`
Fetch details of a specific application.

#### **POST** `/api/v1/credit-applications`
Create a new application.

**Request Body:**
```json
{
  "credit_application": {
    "country": "MX",
    "full_name": "Juan Perez",
    "document_type": "curp",
    "document_number": "ABC123456789012345",
    "monthly_income": 50000,
    "amount_requested": 150000,
    "status": "pending"
  }
}
```

---

### 3. Webhooks
**POST** `/api/webhooks/receive`

External status updates (public endpoint).

**Request Body:**
```json
{
  "application_id": "aa92cd8c-2ecf-4445-9ac6-0dcda74b1bbd",
  "status": "approved",
  "reason": "Risk check passed successfully"
}
```


