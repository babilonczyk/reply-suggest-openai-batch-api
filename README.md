# Reply Suggest

## How it works?

This app is an AI-powered autoresponder system that generates replies to customer messages submitted via various sources (email currently). Each submission can be reviewed, accepted, or rejected by a human operator. Responses are generated using OpenAI's Batch API.

## Install & Run

```bash
bundle
rails db:create
rails db:migrate

# Create a .env file and set your environment variables, including:
# OPENAI_API_KEY=your-key-here

rails s

bundle exec sidekiq -C config/sidekiq.yml
```

## Existing endpoints:

### List all submissions

**GET** `/api/v1/submissions`

Returns a list of all submissions.

#### Example `curl`:

```bash
curl -X GET http://localhost:3000/api/v1/submissions
```

---

### Show specific submission

**GET** `/api/v1/submissions/:id`

Returns a single submission by ID.

#### Example `curl`:

```bash
curl -X GET http://localhost:3000/api/v1/submissions/1
```

---

### Accept submission

**POST** `/api/v1/submissions/:id/accept`

Accepts the generated reply for a submission.

#### Example `curl`:

```bash
curl -X POST http://localhost:3000/api/v1/submissions/1/accept
```

---

### Reject submission

**POST** `/api/v1/submissions/:id/reject`

Rejects the generated reply for a submission. You can optionally include a `review_comment` to explain the reason for rejection.

#### Parameters

| Name             | Type   | Required | Description                           |
| ---------------- | ------ | -------- | ------------------------------------- |
| `review_comment` | string | required | Reason for rejection (shared with AI) |

#### Example `curl`

```bash
curl -X POST http://localhost:3000/api/v1/submissions/2/reject \
  -H "Content-Type: application/json" \
  -d '{"review_comment": "The answer missed the main issue."}'
```

---

### Create a submission

**POST** `/api/v1/submissions`

Creates a new submission from a source (e.g., Email, SMS).

#### Accepted `source_type` values:

- `email`

#### Required fields:

- `source_type`

In case of source_type email:

- `email`
- `message`

#### Example `curl`:

```bash
curl -X POST http://localhost:3000/api/v1/submissions \
  -H "Content-Type: application/json" \
  -d '{
    "submission": {
      "source_type": "email",
      "email": "jan@example.com",
      "message": "My laptop doesn't turn on."
    }
  }'
```
