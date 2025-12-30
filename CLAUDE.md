# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Reporty is a multi-tenant incident reporting platform with anonymous intake, partner dashboards, and cryptographically secure evidence chains. It consists of a Vite+React frontend and a Next.js backend with serverless PDF generation.

## Commands

### Frontend (root directory)
```bash
npm run dev          # Start Vite dev server (port 3000)
npm run build        # Build frontend
```

### Backend (backend/ directory)
```bash
cd backend
npm run dev          # Start Next.js dev server
npm run build        # Build Next.js app
npm run lint         # Run linting
npm test             # Run vitest tests
npm run test -- --run crypto.test.ts  # Run single test file

# Database (Drizzle ORM with PostgreSQL/Neon)
npm run db:generate  # Generate migrations from schema
npm run db:migrate   # Apply migrations
npm run db:studio    # Open Drizzle Studio UI
npm run db:seed      # Seed initial data
npm run db:setup     # Full setup: generate + migrate + seed

npm run keys:gen     # Generate crypto keys
```

## Architecture

### Directory Structure
- `src/` - Frontend (Vite + React 19)
  - `components/` - React components including DefenseReport
  - `services/geminiService.ts` - Google GenAI integration
- `backend/` - Backend (Next.js 15)
  - `src/app/` - Next.js app router (pages + API routes)
  - `src/server/` - Business logic and utilities
  - `drizzle/` - Database schema and migrations
  - `lambda/pdf-generator/` - AWS Lambda for PDF generation
- `docs/` - Documentation

### API Route Structure
- `/api/public/*` - Anonymous intake endpoints (reports, onboarding)
- `/api/partner/*` - Partner portal (requires `x-partner-key` header)
- `/api/admin/*` - Admin operations (requires `x-admin-key` header)
- `/api/internal/*` - Internal callbacks (PDF generation)

### Authentication
- **Admin**: Header `x-admin-key` verified against `ADMIN_API_KEY` env var
- **Partner**: Header `x-partner-key` with bcrypt verification (prefix lookup in DB)

### Data Flow
1. Public intake: Form → `/api/public/reports` → Encrypted payload stored
2. Report access: Public code hash lookup → Decrypt and return
3. PDF generation: Admin request → QStash queue → Lambda renders → Callback stores to R2

### Key Server Modules (`backend/src/server/`)
- `auth.ts` - Admin/partner authentication
- `crypto.ts` - AES-256-GCM encryption, bcrypt hashing
- `db.ts` - Drizzle database connection
- `evidence.ts` / `evidence-verify.ts` - HMAC chain for audit events
- `storage.ts` - R2/S3 file storage
- `pii-guard.ts` - PII detection and redaction
- `sla.ts` - SLA traffic-light calculations

### Database Schema (`backend/drizzle/schema.ts`)
Core tables: `partners`, `tenants`, `users`, `reports`, `report_payloads`, `report_events`, `access_audit`, `evidence_chain`, `defense_packs`

Key patterns:
- Public codes are stored as hashes (not plaintext)
- Payloads encrypted with key versioning
- Events HMAC-chained for tamper evidence

## Environment Variables

See `backend/.env.example` for full list. Key variables:
- `DATABASE_URL` - Neon PostgreSQL connection
- `MASTER_KEY_B64`, `PUBLIC_CODE_SECRET`, `EVIDENCE_HMAC_KEY` - Crypto keys
- `ADMIN_API_KEY` - Admin authentication
- `R2_*` - Cloudflare R2 storage credentials
- `QSTASH_TOKEN`, `PDF_LAMBDA_FUNCTION_URL` - PDF pipeline

---

## Vibe Coding: Effective AI Collaboration

### Philosophy

**"AI is a Pair Programming Partner, Not Just a Tool"**

Collaboration with Claude is not mere code generation—it's a process of sharing thought processes and solving problems together.

### 1. Context Provision Principles

**Provide Sufficient Background:**
```markdown
# BAD: No context
"Create a login feature"

# GOOD: Rich context
"Our project uses Next.js 14 + Supabase.
Auth-related code is in /app/auth folder.
Following existing patterns, add OAuth login.
Reference: src/app/auth/login/page.tsx"
```

**Context Checklist:**
- [ ] Specify project tech stack
- [ ] Provide relevant file paths
- [ ] Mention existing patterns/conventions
- [ ] Describe expected output format
- [ ] State constraints and considerations

### 2. Iterative Refinement Cycle

```
VIBE CODING CYCLE

1. SPECIFY    → Describe desired functionality specifically
2. GENERATE   → Claude generates initial code
3. REVIEW     → Review generated code yourself
4. REFINE     → Provide feedback for modifications
5. VERIFY     → Run tests and verify edge cases

Repeat 2-5 as needed
```

### 3. Effective Prompt Patterns

**Pattern 1: Role Assignment**
```
"You are a senior React developer with 10 years experience.
Review this component and suggest improvements."
```

**Pattern 2: Step-by-Step Requests**
```
"Proceed in this order:
1. Analyze current code problems
2. Present 3 improvement options
3. Refactor using the most suitable option
4. Explain the changes"
```

**Pattern 3: Constraint Specification**
```
"Implement with these constraints:
- Maintain existing API contract
- No new dependencies
- Test coverage >= 80%"
```

**Pattern 4: Example-Based Requests**
```
"Create OrderService.ts following the same pattern as
UserService.ts. Especially follow the error handling approach."
```

### 4. Boundaries

**DO NOT delegate to Claude:**
- Security credential generation/management
- Direct production DB manipulation
- Code deployment without verification
- Sensitive business logic full delegation

**Human verification REQUIRED:**
- Security-related code (auth, permissions)
- Financial transaction logic
- Personal data processing code
- Irreversible operations
- External API integration code

### 5. Vibe Coding Checklist

```
Before Starting:
- [ ] Shared CLAUDE.md file with Claude?
- [ ] Explained project structure and conventions?
- [ ] Clearly defined task objectives?

During Coding:
- [ ] Providing sufficient context?
- [ ] Understanding generated code?
- [ ] Giving specific feedback?

After Coding:
- [ ] Personally reviewed generated code?
- [ ] Ran tests?
- [ ] Verified security-related code?
- [ ] Removed AI mentions from commit messages?
```

