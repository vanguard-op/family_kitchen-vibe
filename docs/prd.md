## PRD: Family Kitchen (The Royal Hearth)

### 1. Product overview

#### 1.1 Document title and version
- PRD: Family Kitchen (The Royal Hearth)
- Version: 1.0

#### 1.2 Product summary
Family Kitchen is a mobile-first kitchen management system combining inventory, meal planning, and decision workflows under a playful “Kingdom” metaphor.  
Phase 1 delivers core solo/family controls, allergy-aware inventory, and chef mode. Phase 2 adds democratic meal voting, visitor access, and schedule planning. Phase 3 provides automatic depletion, waste auditing, and power cooking interfaces.

### 2. Goals

#### 2.1 Business goals
- Launch MVP for single-family homes with immediate value in pantry management.
- Reduce food waste by 25% in first 6 months with expiry alerts + depletion tracking.
- Establish groundwork for AI meal recommendations and shared household planning.

#### 2.2 User goals
- Quickly track perishable ingredients and avoid accidental spoilage.
- Ensure family dietary safety with allergy vault checks.
- Coordinate meal decisions and chef responsibilities by role.
- Have an intuitive “Chef Mode” cooking workflow.

#### 2.3 Non-goals
- Not in scope: full supply chain procurement integration.
- Not in scope: voice command NLP in Early Phase (plan Phase 3 prototype only).
- Not in scope: enterprise kitchens / commercial HACCP compliance in initial version.

### 3. User personas

#### 3.1 Key user types
- Family Organizer
- Home Chef
- Casual Contributor
- Guest/Visitor
- Solo Home Cook

#### 3.2 Basic persona details
- **Family Organizer**: sets kingdom, invites members, checks shortages.
- **Home Chef**: manages recipes, activates Chef Mode, tracks cooking steps.
- **Casual Contributor**: adds inventory items, votes on meal ballots.
- **Guest/Visitor**: temporary access with restricted permissions.
- **Solo Home Cook**: uses solo mode and basic inventory/allergy safeguards.

#### 3.3 Role-based access
- **King/Queen**: full admin (kingdom, members, veto ballots, role assignment).
- **Chef**: cooking workflows, recipe management, activate/deactivate Chef Mode.
- **Prince/Princess**: inventory updates, voting, meal planning.
- **Visitor**: read-only or limited interaction when granted.
- **Admin (system)**: authentication, audit logs, security config.

### 4. Functional requirements

- **Solo/family mode setup** (Priority: High)
  - user profile creates or joins kingdom; solo defaults to single-member kingdom.

- **Role management (Royal Registry)** (Priority: High)
  - assign roles in kingdom, enforce `current_chef_id`, role hierarchy & veto rules.

- **Allergy vault** (Priority: High)
  - member-level allergens, cross-check when adding recipes or tracking food.

- **Inventory CRUD + expiration alerts** (Priority: High)
  - manual + barcode item intake, best_before, use_count, expiring-soon push notification.

- **Chef mode UI** (Priority: High)
  - UI toggle to chef workflow; kitchen-centric large controls and step emphasis.

- **Meal ballot voting** (Priority: Medium)
  - propose meals, vote, tally, king/queen veto.

- **Visitor onboarding** (Priority: Medium)
  - generates QR onboarding to join as temporary guest.

- **Food schedule calendar** (Priority: Medium)
  - display and edit ordered meals from winning ballots.

- **Recipe suggestion engine** (Priority: Medium)
  - AI suggestions by inventory availability and allergy preferences.

- **Automatic depletion** (Priority: High Complexity)
  - mark recipe done; deduct ingredients from inventory.

- **Waste audit** (Priority: High Complexity)
  - log discards with reason, calculate waste points.

### 5. User experience

#### 5.1 Entry points & first-time user flow
- signup/login -> choose mode solo/family -> create/join Kingdom -> set allergies -> add inventory.

#### 5.2 Core experience
- **Home dashboard**: low-stock + expiring soon card.
  - ensures quick action.
- **Inventory tab**: add scan/manual, edit, archive.
  - ensures data correctness.
- **Recipe tab**: build recipes, ingredient links, allergy check.
- **Chef workflow**: one-button ahead/step wizard with timer.
- **Ballot flow**: submit options, vote, see result, schedule.

#### 5.3 Advanced features & edge cases
- show “allergy conflict” warnings for tracked members.
- history of automatic depletion actions.
- support offline edits and sync conflict resolution.
- handle duplicate inventory from varied UPCs.

#### 5.4 UI/UX highlights
- mobile-first accessible controls.
- high contrast and large text in Chef Mode.
- in-app prompts for chef handover and role change.
- pre-release guard for “veto selected” ballot state.

### 6. Narrative
A Kingdom organizer signs into Family Kitchen, enters inventory, and prints a “load-bearing” allergy vault. The team votes on meals, the king selects the winner, the chef activates Chef Mode, and the kitchen tracks ingredient usage and waste to refine planning with weekly feedback.

### 7. Success metrics

#### 7.1 User-centric
- daily active users by role.
- reduction in expired inventory.
- number of meal ballots completed.

#### 7.2 Business
- onboarding conversion (signup → first inventory item) >= 40%.
- retention week 4 >= 30%.
- escalation tickets due to role/auth misbehavior < 5% in first quarter.

#### 7.3 Technical
- API latency < 200ms p95.
- nightly data sync success > 99%.
- auth failure rate < 1%.

### 8. Technical considerations

#### 8.1 Integration points
- api FastAPI endpoints for kingdom/member/inventory/recipe/ballot.
- NoSQL storage layer (Firestore/Dynamo/Mongo).
- mobile app Flutter client sync and local cache.

#### 8.2 Data storage & privacy
- encrypt PII at rest (`user.email`, `allergies`).
- tokenized UID references in family data.
- least-privilege RBAC.

#### 8.3 Scalability & performance
- partition by `kingdom_id` in DB.
- pagination for inventory, ballot/results.
- support eventual consistency for multi-member sync.

#### 8.4 Potential challenges
- member role conflicts and concurrent chef handovers.
- recipe-allergy mismatch in non-standard ingredient names.
- increment/decrement inventory after auto-depletion.

### 9. Milestones & sequencing

#### 9.1 Project estimate
- Small: 12 weeks (Phase 1)
- Medium: +8 weeks (Phase 2)
- Large: +10 weeks (Phase 3)

#### 9.2 Team size & composition
- 2 backend engineers
- 2 mobile engineers
- 1 UX designer
- 1 QA engineer
- 1 product owner

#### 9.3 Suggested phases
- **Phase 1**: core kingdom, inventory, allergy, chef mode (6 weeks)
  - MVP functional flows.
- **Phase 2**: ballots, visitor, schedule, recipe suggestions (5 weeks)
  - collaborative features.
- **Phase 3**: depletion, waste audit, Chef Cockpit (5 weeks)
  - automation and analytics.

### 10. User stories

#### 10.1 Kingdom creation
- ID: GH-001
- Description: As a user, I can create a new Kingdom with mode solo/family.
- Acceptance criteria:
  - creation API returns kingdom ID.
  - default role assignment.
  - new kingdom dashboard loads.

#### 10.2 Member role assignment
- ID: GH-002
- Description: As King/Queen, I can assign member roles.
- Acceptance criteria:
  - role options {king,queen,prince,princess,chef,visitor}.
  - only one current chef active.
  - non-admin cannot change role.

#### 10.3 Allergy vault registration
- ID: GH-003
- Description: As a member, I can register allergens.
- Acceptance criteria:
  - allergen list saved per member.
  - recipe creation checks against all members.
  - block recipe if conflict exists for any chosen household members.

#### 10.4 Inventory CRUD + expiring alerts
- ID: GH-004
- Description: As a user, I can add/edit/delete inventory items with expiry.
- Acceptance criteria:
  - item stored with best_before.
  - expiring soon flag appears for < 5 days.
  - alert sent to dashboard/push.

#### 10.5 Chef mode toggle
- ID: GH-005
- Description: As a eligible chef, I can activate Chef Mode.
- Acceptance criteria:
  - Chef Mode button visible and toggles state.
  - route to cooking workflow.
  - restrict non-chef roles.

#### 10.6 Meal ballot voting
- ID: GH-006
- Description: As a member, I can propose meals and vote.
- Acceptance criteria:
  - ballot creates options.
  - members can vote once.
  - king/queen veto overrides winner.

#### 10.7 Visitor onboarding
- ID: GH-007
- Description: As a member, I can invite temporary visitors by QR.
- Acceptance criteria:
  - QR payload includes kingdom + expiry.
  - visitor can join with restrictions.
  - temporary TTL enforced.

#### 10.8 Auto depletion handling
- ID: GH-008
- Description: As a chef, I can mark recipe complete and deduce inventory.
- Acceptance criteria:
  - ingredients decremented safely.
  - handles insufficient inventory cases gracefully.
  - audit record created.

#### 10.9 Waste audit log
- ID: GH-009
- Description: As a member, I can log wasted food and reason.
- Acceptance criteria:
  - reasons {expired, spoiled, over-purchased}.
  - waste points computed.
  - report view created.

#### 10.10 Security/auth flow
- ID: GH-010
- Description: As any user, auth is enforced and role checks protect endpoints.
- Acceptance criteria:
  - OAuth2 password flow + JWT for API.
  - Role-based access on all key routes.
  - refresh token endpoint.
  - audit log entries on auth failures.
