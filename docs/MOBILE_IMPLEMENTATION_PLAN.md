# Phase 1 Mobile Implementation Plan - family_kitchen

Created: 2026-03-27
Framework: Flutter (Dart)
Status: Implementation Ready

## 1. Screen Flow Map

Home → Inventory List (search/filter) → Inventory Add (form + expiry date)
Home → Member Management (role assignment) 
Home → Allergy Setup (per-member allergens)
Home → Chef Mode (toggle to cooking workflow)

First-time: Auth → Kingdom Setup (solo/family) → Home

---

## 2. Screens to Implement (MOB-001 to MOB-005)

### MOB-001: Home Screen Dashboard
- Dashboard cards: low stock, expiring items
- Pull-to-refresh
- Chef Mode toggle button
- Offline cache + sync support
- **Provider:** InventoryProvider (fetchDashboard)
- **API:** GET /kingdom/{kingdom_id}/dashboard

### MOB-002: Inventory CRUD + List
- List view with search & filters (All/Expiring/Low Stock)
- Add item screen: name, quantity, unit, expiry date, category
- Expiry alert badges
- Offline queuing + sync
- **Provider:** InventoryProvider (getInventory, addItem)
- **API:** GET/POST /kingdom/{kingdom_id}/inventory

### MOB-003: Member Management
- Member list with role assignment dropdown
- Roles: admin, member, viewer, chef_mode_user
- Permission check (admin only)
- Confirmation dialog
- **Provider:** KingdomProvider (members, updateMemberRole) - CREATE
- **API:** GET/POST /kingdom/{kingdom_id}/members

### MOB-004: Allergy Vault
- Member selector + allergen list per member
- Add allergen form with severity (mild/moderate/severe/life-threatening)
- Validation: no duplicates
- **Provider:** AllergyProvider (allergens) - CREATE
- **API:** GET/POST/DELETE /kingdom/{kingdom_id}/members/{member_id}/allergies

### MOB-005: Kingdom Setup (First-time User)
- Form: Kingdom name, mode selector (solo/family), timezone picker
- POST to backend, store kingdom_id
- Navigate to home on success
- **Provider:** KingdomProvider (createKingdom)
- **API:** POST /kingdom (NEEDS TO BE CREATED BY BACKEND)

---

## 3. Provider Structure Needed

### Existing
- auth_provider.dart (expand: add kingdom_id, role)
- inventory_provider.dart (expand: fetchDashboard, getInventory, addItem)

### New
- kingdom_provider.dart (members list, createKingdom, updateMemberRole)
- allergy_provider.dart (allergens by member, add/remove operations)

All providers need:
- isLoading state, error state
- Offline-first: SQLite caching + sync_manager integration

---

## 4. Offline Strategy

SQLite Tables:
- INVENTORY (id, kingdom_id, name, quantity, unit, best_before, synced, ...)
- MEMBERS (id, kingdom_id, email, role, synced, ...)
- ALLERGIES (id, member_id, allergen_name, severity, synced, ...)
- SYNC_QUEUE (operation, table_name, record_id, payload, retry_count, ...)

Flow: Write local + add to queue → On online: batch push & sync

---

## 5. Blocking Dependencies - Backend MUST Confirm

❌ MISSING:
1. POST /kingdom endpoint (for MOB-005)
   Body: { name, mode, timezone }
   Response: { kingdom_id, name, mode, timezone, created_at }

2. Allergy endpoints (for MOB-004)
   GET/POST/DELETE /kingdom/{kingdom_id}/members/{member_id}/allergies
   POST body: { allergen_name, severity }
   Severity enum: mild, moderate, severe, life-threatening

3. Confirm Dashboard schema matches:
   { low_stock: [], expiring_soon: [], total_items, total_members }

4. Confirm inventory return includes: item_id, name, quantity, unit, best_before, created_at

5. Confirm member roles are: admin, member, viewer, chef_mode_user

6. Confirm error responses follow: { detail: \\'..\\', error_code: \\'...' }

---

## 6. Acceptance Criteria (Phase 1 Complete)

✅ All 5 screens implemented with working UI
✅ All API endpoints integrated & tested
✅ Offline-first caching working (SQLite + sync queue)
✅ 80%+ widget test coverage
✅ Error + loading states handled
✅ Navigation smooth (no dead-ends)
✅ Performance: Dashboard loads < 1s
✅ Security: Tokens secure, no PII in logs

