# Database Schema

## Collections

### users

```firestore
collection: users
document: {user_id}
  - email: string (encrypted)
  - password_hash: string
  - created_at: timestamp
  - updated_at: timestamp
  - last_login: timestamp (optional)
```

### kingdoms

```firestore
collection: kingdoms
document: {kingdom_id}
  - name: string
  - mode: enum ("solo", "family")
  - timezone: string (default: "UTC")
  - created_by: string (user_id)
  - created_at: timestamp
  - updated_at: timestamp
  
  subcollection: members
  document: {member_id}
    - user_id: string
    - name: string
    - role: enum ("King", "Queen", "Prince", "Princess", "Chef", "Visitor")
    - email: string (encrypted)
    - created_at: timestamp
    - updated_at: timestamp
    - visitor_expires_at: timestamp (optional)
  
  subcollection: inventory
  document: {item_id}
    - name: string
    - quantity: float
    - unit: enum ("g", "kg", "ml", "l", "count", "oz", "cup", "tbsp", "tsp")
    - best_before: date
    - barcode: string (optional, indexed)
    - added_by: string (member_id)
    - added_at: timestamp
    - updated_at: timestamp
    - archived_at: timestamp (null if active)
    - use_count: integer (incremented on depletion)
  
  subcollection: audit_logs
  document: {log_id}
    - event_type: enum ("role_change", "auth_failure", "inventory_add", "inventory_delete")
    - actor_id: string (member_id or system)
    - resource_id: string
    - timestamp: timestamp
    - details: map (JSON object)
```

### members

```firestore
collection: members
document: {member_id}
  - kingdom_id: string (indexed)
  - user_id: string
  - name: string
  - role: string
  
  subcollection: allergies
  document: {allergen_id}
    - allergen_name: string (encrypted)
    - severity: enum ("mild", "moderate", "severe")
    - added_at: timestamp
    - updated_at: timestamp
  
  subcollection: chef_mode
  document: "status"
    - active: boolean
    - activated_at: timestamp (optional)
    - deactivated_at: timestamp (optional)
    - device_id: string (optional, for Phase 2)
```

### refresh_tokens

```firestore
collection: refresh_tokens
document: {token_id}
  - user_id: string (indexed)
  - token_hash: string
  - expires_at: timestamp
  - revoked_at: timestamp (optional)
  - created_at: timestamp
```

## Indexes

### Composite Indexes

- `kingdoms/{kingdom_id}/inventory` by `best_before` ASC, `archived_at` ASC
- `kingdoms/{kingdom_id}/inventory` by `quantity` ASC, `archived_at` ASC
- `kingdoms/{kingdom_id}/audit_logs` by `event_type` ASC, `timestamp` DESC
- `refresh_tokens` by `user_id` ASC, `expires_at` DESC

### Single-Field Indexes

- `users.email` (encrypted, indexed for uniqueness check)
- `kingdoms.created_at` (for listing/pagination)
- `members.kingdom_id` (multi-tenancy partition)
- `inventory.barcode` (for duplicate detection)
- `inventory.archived_at` (soft delete filtering)

## Encryption Strategy

### Fields Encrypted at Rest (Application-Layer)

- `users.email`
- `members.email`
- `members.allergies.allergen_name`

### Encryption Method

- Library: Tink (or cryptography.io)
- Key Source: GCP Secret Manager
- Algorithm: AES-256-GCM

## Data Retention

- **Active Data:** Indefinite (user-managed deletion)
- **Soft-Deleted Inventory:** 90 days before permanent deletion
- **Audit Logs:** 1 year
- **Refresh Tokens:** 7 days (from creation) or until revoked
- **Backups:** Daily snapshots, 30-day retention
