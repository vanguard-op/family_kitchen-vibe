# API Specification

## Base URL
- **Development:** `http://localhost:8000`
- **Production:** `https://api.family-kitchen.com` (TBD)

## Authentication

All endpoints except `/auth/signup` and `/auth/login` require JWT token in `Authorization` header:

```
Authorization: Bearer {access_token}
```

## Error Responses

All error responses follow this format:

```json
{
  "detail": "Error message",
  "status_code": 400,
  "error_code": "VALIDATION_ERROR"
}
```

## Endpoints

### Authentication

#### POST /auth/signup
Create a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (201):**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "user_id": "user-uuid-123"
}
```

#### POST /auth/login
Authenticate user and get tokens.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer"
}
```

#### POST /auth/refresh
Refresh the access token.

**Request:**
```json
{
  "refresh_token": "eyJ..."
}
```

**Response (200):**
```json
{
  "access_token": "eyJ...",
  "token_type": "bearer"
}
```

#### POST /auth/logout
Logout current user.

**Request:**
```
Authorization: Bearer {access_token}
```

**Response (204):** No content

### Kingdom

#### POST /kingdom
Create a new kingdom.

**Request:**
```json
{
  "name": "Smith Family Kitchen",
  "mode": "family",
  "member_ids": ["user-123", "user-456"]
}
```

**Response (201):**
```json
{
  "kingdom_id": "kingdom-abc123",
  "name": "Smith Family Kitchen",
  "mode": "family",
  "created_by": "user-123",
  "timezone": "UTC",
  "member_count": 2,
  "created_at": "2026-03-26T10:30:00Z"
}
```

#### GET /kingdom/{kingdom_id}
Get kingdom details.

**Response (200):** Same as POST response

#### GET /kingdom/{kingdom_id}/members
List kingdom members.

**Response (200):**
```json
{
  "members": [
    {
      "member_id": "member-123",
      "name": "Alice",
      "role": "King",
      "user_id": "user-123"
    }
  ]
}
```

#### POST /kingdom/{kingdom_id}/members/{member_id}/assign-role
Assign role to member.

**Request:**
```json
{
  "role": "Chef"
}
```

**Response (200):**
```json
{
  "member_id": "member-456",
  "role": "Chef",
  "previous_role": "Prince",
  "changed_at": "2026-03-26T10:35:00Z"
}
```

### Inventory

#### POST /kingdom/{kingdom_id}/inventory
Add inventory item.

**Request:**
```json
{
  "name": "Milk",
  "quantity": 2,
  "unit": "l",
  "best_before": "2026-04-02",
  "barcode": "1234567890123"
}
```

**Response (201):**
```json
{
  "item_id": "item-abc123",
  "name": "Milk",
  "quantity": 2,
  "unit": "l",
  "best_before": "2026-04-02",
  "expiring_soon": false,
  "added_at": "2026-03-26T11:00:00Z"
}
```

#### GET /kingdom/{kingdom_id}/inventory
List inventory items.

**Query Parameters:**
- `page` (int, default: 1) - Page number
- `sort_by` (string, default: "added_at") - Sort field (best_before, quantity, added_at)

**Response (200):**
```json
{
  "items": [
    {
      "item_id": "item-xyz789",
      "name": "Yogurt",
      "quantity": 1,
      "unit": "count",
      "best_before": "2026-03-28",
      "expiring_soon": true,
      "added_at": "2026-03-25T11:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 50,
    "total": 87
  }
}
```

#### GET /kingdom/{kingdom_id}/dashboard
Get dashboard summary (low stock + expiring soon).

**Response (200):**
```json
{
  "low_stock": [...],
  "expiring_soon": [...],
  "last_updated": "2026-03-26T11:20:00Z"
}
```

### Allergies

#### POST /member/{member_id}/allergies
Add allergen.

**Request:**
```json
{
  "allergen_name": "shellfish",
  "severity": "severe"
}
```

**Response (201):**
```json
{
  "allergen_id": "allergen-789",
  "allergen_name": "shellfish",
  "severity": "severe",
  "added_at": "2026-03-26T10:40:00Z"
}
```

#### GET /member/{member_id}/allergies
List allergies.

**Response (200):**
```json
{
  "allergies": [
    {
      "allergen_id": "allergen-789",
      "allergen_name": "shellfish",
      "severity": "severe"
    }
  ]
}
```
