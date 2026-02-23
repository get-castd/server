# CASTD Persistence — Working with Databases

> CASTD uses SQLite for all persistence. There is no ORM, no model layer,
> no migration files. Tables and columns are created on first use. You write
> HTML templates; the server handles the SQL.

## Core Concept

The `{* *}` syntax (persistence blocks) provides four operations:

| Operation | Syntax | Purpose |
|-----------|--------|---------|
| **Create** | `{* write db.table *}...{* endwrite *}` | Insert a record |
| **Read** | `{* read db.table *}...{* endread *}` | Query records |
| **Update** | `{* update db.table *}...{* endupdate *}` | Modify records |
| **Delete** | `{* delete db.table | where ... *}` | Remove records |

The `db.` prefix tells the server this is a database operation. The part
after `db.` is the table name.

---

## Built-in Variables

Persistence blocks use several built-in variables. Familiarise yourself
with these before the tutorial — they appear throughout the examples.

| Variable | Source | Content |
|----------|--------|---------|
| `user` | Session | Current user object (or null) |
| `user.id` | Session | User ID |
| `user.email` | Session | Email address |
| `user.role` | Session | Role string |
| `form.*` | POST body | Submitted form data |
| `route.*` | URL | Path parameters |
| `now` | Server | Current Unix timestamp |
| `redirect` | Assignment | Set to trigger HTTP redirect |

---

## Step by Step: Building a Blog

### 1. Creating Records

The first `{* write *}` to a table creates it automatically. Columns are
inferred from the fields you assign:

```html
{* write db.posts *}
  {{ title = form.title }}
  {{ slug = form.title | slug }}
  {{ content = form.content }}
  {{ author = user.id }}
  {{ published = false }}
{* endwrite *}
```

This creates a `posts` table with columns `title` (TEXT), `slug` (TEXT),
`content` (TEXT), `author` (TEXT), and `published` (INTEGER). Every table
automatically receives:

- `id` — INTEGER PRIMARY KEY AUTOINCREMENT
- `created` — Unix timestamp (set on insert)
- `updated` — Unix timestamp (set on insert)

If you later write a field that does not exist yet, the column is added
automatically via `ALTER TABLE`.

### 2. Reading Records

**List all posts:**

```html
{* read db.posts *}
  {! each items !}
    <article>
      <h2><a href="/blog/{{ item.slug }}">{{ item.title }}</a></h2>
      <time>{{ item.created | date }}</time>
    </article>
  {! endeach !}
{* endread *}
```

The result set is available as `items` inside the block. Each record is
accessed as `item.*`.

**With filters:**

```html
{* read db.posts | where published=true | order=created desc | limit=10 *}
  {! each items !}
    <h2>{{ item.title }}</h2>
  {! endeach !}
{* endread *}
```

**Single record (e.g. detail page):**

```html
{* read db.posts | where slug=route.slug *}
  <article>
    <h1>{{ item.title }}</h1>
    <div>{{ item.content | raw }}</div>
  </article>
{* endread *}
```

### 3. Updating Records

```html
{* update db.posts | where id=route.id *}
  {{ title = form.title }}
  {{ content = form.content }}
  {{ updated = now }}
{* endupdate *}
```

The `where` clause is mandatory for updates — CASTD will not update without
a condition to prevent accidental mass updates.

### 4. Deleting Records

```html
{* delete db.posts | where id=route.id *}
```

Delete is a single statement with no block body. The `where` clause is
mandatory — CASTD will not execute a delete without a condition.

---

## Query Modifiers

Modifiers filter and shape query results. They are appended after a `|`:

| Modifier | Example | Effect |
|----------|---------|--------|
| `where` | `where published=true` | Filter rows (AND logic) |
| `where` | `where active=true, role="admin"` | Multiple conditions |
| `order` | `order=created desc` | Sort results |
| `limit` | `limit=10` | Maximum rows returned |
| `offset` | `offset=20` | Skip rows (for pagination) |

**Where operators:**

| Operator | Example |
|----------|---------|
| `=` | `where id=5` |
| `!=` | `where status!=draft` |
| `>` | `where views>100` |
| `<` | `where price<50` |
| `>=` | `where created>=1700000000` |
| `<=` | `where updated<=1700000000` |

Multiple `where` conditions are combined with AND:

```html
{* read db.posts | where published=true, featured=true | order=created desc | limit=10 *}
```

---

## Context Filtering

CASTD has a tag-based Context system that provides O(1) lookups. You can
combine Context filtering with database queries:

```html
{* read db.posts | context status:published, topic:rust | where views>100 *}
  {! each items !}
    <h2>{{ item.title }}</h2>
  {! endeach !}
{* endread *}
```

**How this works internally:**

1. Context system finds all entity IDs tagged `status:published` AND `topic:rust`
2. Database query adds `WHERE id IN (...)` with those IDs, plus `views > 100`
3. Result: only published Rust posts with more than 100 views

Tags are assigned when writing:

```html
{* write db.posts | tags=status:published, topic:rust *}
  {{ title = form.title }}
{* endwrite *}
```

See [12-context.md](12-context.md) for the full Context specification.

---

## Authentication

CASTD has built-in user management with Argon2 password hashing and
session-based authentication.

### Register

```html
{* auth register | role="user" *}
  {! if error !}
    <p class="error">{{ error }}</p>
  {! endif !}
  {! if success !}
    {{ redirect = "/welcome" }}
  {! endif !}

  <form method="POST">
    <input name="email" type="email" required>
    <input name="password" type="password" required>
    <input name="password_confirm" type="password" required>
    <button type="submit">Register</button>
  </form>
{* endauth *}
```

The `role` modifier sets the default role. If `password_confirm` is
present, the server validates that both passwords match. On success,
the user is automatically logged in.

### Login

```html
{* auth login *}
  {! if error !}
    <p class="error">{{ error }}</p>
  {! endif !}
  {! if success !}
    {{ redirect = "/dashboard" }}
  {! endif !}

  <form method="POST">
    <input name="email" type="email" required>
    <input name="password" type="password" required>
    <button type="submit">Sign in</button>
  </form>
{* endauth *}
```

On successful login, the server:
1. Verifies the password against the Argon2 hash
2. Creates a session with a cryptographically secure token
3. Sets the session cookie (valid for 7 days)
4. Populates `user.*` variables in the template context

### Logout

```html
{* auth logout *}
```

Single statement. Invalidates the session and clears the cookie.

---

## Access Control

The `{* require *}` block guards content behind conditions. If the
condition fails, the block is silently omitted — no redirect, no error
page. This keeps templates clean and security explicit.

```html
{* require logged-in *}
  <p>Welcome, {{ user.email }}.</p>
{* endrequire *}

{* require logged-out *}
  <a href="/login">Sign in</a>
{* endrequire *}

{* require role="admin" *}
  <a href="/admin">Admin Panel</a>
{* endrequire *}

{* require permission="posts.write" *}
  <button>New Post</button>
{* endrequire *}
```

### Role Hierarchy

Roles are hierarchical. Higher roles inherit all permissions of lower roles:

```
guest < user < editor < admin
```

| Role | Inherits | Default Permissions |
|------|----------|---------------------|
| guest | — | (none) |
| user | guest | posts.read, pages.read |
| editor | user | posts.write, posts.delete, pages.write |
| admin | editor | (all) |

Custom roles are matched exactly — only the four built-in roles use
hierarchy.

---

## Security Model

CASTD is designed so that **templates are trusted but user input is not**.
Here is how the system protects against common attacks.

### Why CAST Is Not Like JavaScript

If you come from front-end development, you may instinctively worry about
code injection — and rightly so. In the browser, a `<script>` tag injected
via user input will execute, because the browser interprets everything it
receives as potentially executable. That is how XSS works.

**CAST does not work this way.** The fundamental difference:

| | Client-side (JavaScript) | Server-side (CAST) |
|---|---|---|
| **When is code parsed?** | Every time the browser renders the page | Once, when the server loads the template file |
| **What gets parsed?** | The entire HTML response, including injected content | Only `.html` files from the `templates/` directory on disc |
| **Can user input become code?** | Yes — that is the entire XSS problem | No — user input is string data, never re-parsed |
| **Is there an `eval`?** | `eval()`, `Function()`, `innerHTML`... | No equivalent exists |

A browser is a general-purpose runtime that executes anything in a
`<script>` tag. The CASTD server is a template processor that reads
template files once and then fills in values. User input enters the
process as data — like ink on a printed form, not like a new paragraph
in the form's design.

### CAST Injection

**The scenario:** A user opens the browser's developer tools and submits
a form field containing CAST syntax, e.g. `{* delete db.users *}`,
hoping the server will execute it.

**Why this is architecturally impossible:** CAST templates are parsed from
files on disc when the server starts. User input arrives later, as values
to fill into an already-parsed template. There is no step where user input
is fed back into the parser. The two never meet.

When you write:

```html
{* write db.posts *}
  {{ title = form.title }}
{* endwrite *}
```

The value of `form.title` is a plain string — always. Even if someone
submits `{* delete db.users *}` as a title, it is stored as the literal
text `{* delete db.users *}`. It will never be interpreted as a CAST
instruction, because the server has no mechanism to do so. There is no
`eval`, no second parsing pass, no dynamic template compilation.

**The principle:** Templates are code. User input is data. They are
processed by entirely separate mechanisms that do not interact.

### Cross-Site Scripting (XSS)

**The threat:** A user submits `<script>alert(1)</script>` as a form
value, hoping it will execute in other users' browsers.

**The protection:** All `{{ }}` output is HTML-escaped by default.
Dangerous characters are converted to harmless entities:

| Character | Escaped To |
|-----------|------------|
| `<` | `&lt;` |
| `>` | `&gt;` |
| `&` | `&amp;` |
| `"` | `&quot;` |
| `'` | `&#x27;` |

```html
{# Safe — escaped automatically: #}
<p>{{ item.title }}</p>
{# Output: &lt;script&gt;alert(1)&lt;/script&gt; #}

{# Raw output — only when the author explicitly opts in: #}
<div>{{ item.content | raw }}</div>
```

The `| raw` modifier bypasses escaping. Use it only for content you
control (e.g. your own HTML in a rich text field), never for
unvalidated user input.

### SQL Injection

**The threat:** A user submits `'; DROP TABLE posts; --` as a form value.

**The protection:** All database operations use parameterised queries.
Values from form fields, route parameters, and template variables are
always passed as SQL parameters, never interpolated into query strings.

Additionally, table and column names are validated with a strict
identifier check:

- Only ASCII alphanumeric characters and underscores
- Maximum 64 characters
- Must not start with a digit
- Any name failing this check is rejected before reaching SQLite

### Write Protection

Write operations (`write`, `update`, `delete`) should always be behind
an access control gate:

```html
{* require role="editor" *}
  {* write db.posts *}
    {{ title = form.title }}
  {* endwrite *}
{* endrequire *}
```

Without `{* require *}`, any visitor could submit the form. The
`require` block ensures only authenticated users with the correct role
can trigger the write.

**Best practice pattern:**

```html
{# Public: read-only #}
{* read db.posts | where published=true | limit=10 *}
  {! each items !}
    <h2>{{ item.title }}</h2>
  {! endeach !}
{* endread *}

{# Protected: write operations #}
{* require role="editor" *}
  {* write db.posts *}
    {{ title = form.title }}
    {{ content = form.content }}
    {{ author = user.id }}
  {* endwrite *}
{* endrequire *}
```

### Delete Safety

The server refuses to execute `DELETE` without a `where` clause. This
prevents accidental deletion of all records:

```html
{# This works: #}
{* delete db.posts | where id=route.id *}

{# This is silently rejected: #}
{* delete db.posts *}
```

### Session Security

- Passwords are hashed with **Argon2** (memory-hard, salt per user)
- Session tokens are 32 bytes of cryptographically secure randomness
- Sessions expire after 7 days
- Expired sessions are automatically cleaned up
- Deleting a user cascades to all sessions (immediate invalidation)

---

## Complete Example: Blog with Authentication

A minimal blog with public reading and protected writing:

**`templates/blog/index.html`** — List posts:

```html
<h1>Blog</h1>

{* read db.posts | where published=true | order=created desc | limit=20 *}
  {! each items !}
    <article>
      <h2><a href="/blog/{{ item.slug }}">{{ item.title }}</a></h2>
      <time>{{ item.created | date }}</time>
    </article>
  {! endeach !}
{* endread *}

{* require role="editor" *}
  <a href="/blog/new">Write Post</a>
{* endrequire *}
```

**`templates/blog/post.html`** — Single post:

```html
{* read db.posts | where slug=route.slug *}
  <article>
    <h1>{{ item.title }}</h1>
    <div>{{ item.content | raw }}</div>
  </article>

  {* require role="editor" *}
    <a href="/blog/edit/{{ item.id }}">Edit</a>
  {* endrequire *}
{* endread *}
```

**`templates/blog/new.html`** — Create post (protected):

```html
{* require role="editor" *}
  {* write db.posts *}
    {{ title = form.title }}
    {{ slug = form.title | slug }}
    {{ content = form.content }}
    {{ author = user.id }}
    {{ published = true }}
  {* endwrite *}

  {! if success !}
    {{ redirect = "/blog" }}
  {! endif !}

  <h1>New Post</h1>
  <form method="POST">
    <input name="title" required>
    <textarea name="content" required></textarea>
    <button type="submit">Publish</button>
  </form>
{* endrequire *}
```

**`templates/login.html`** — Login page:

```html
{* auth login *}
  {! if error !}
    <p class="error">{{ error }}</p>
  {! endif !}
  {! if success !}
    {{ redirect = "/blog" }}
  {! endif !}

  <form method="POST">
    <input name="email" type="email" required>
    <input name="password" type="password" required>
    <button type="submit">Sign in</button>
  </form>
{* endauth *}
```

---

## Data Management

CASTD provides three operations for database backup, export, and import.
All store files in a `backups/` directory alongside the database file.

| Operation | Syntax | Effect |
|-----------|--------|--------|
| **Backup** | `cn.db.backup()` | Atomic binary copy via `VACUUM INTO` — fast, not portable |
| **Export** | `cn.db.export()` | Portable SQL dump (`CREATE TABLE` + `INSERT INTO`) |
| **Import** | `cn.db.import(file)` | Drop all tables, execute SQL dump — **destructive** |

### Backup

```lua
local filename = cn.db.backup()
-- Returns: "castd_backup_1708700000000000_a7f3b2.db"
```

Creates an atomic `.db` snapshot using SQLite's `VACUUM INTO`. Useful
for quick snapshots before risky operations. The file is a standalone
SQLite database.

### Export

```lua
local filename = cn.db.export()
-- Returns: "castd_export_1708700000000000_c9d4e1.sql"
```

Produces a `.sql` file with `CREATE TABLE`, `CREATE INDEX`, and
`INSERT INTO` statements. The output is compatible with any SQLite
instance — transfer it to another system and import it there.

FTS virtual table shadow tables are excluded automatically (their data
is managed by the virtual table itself).

### Import

```lua
local pre_import_backup = cn.db.import("castd_export_1708700000000000_c9d4e1.sql")
-- Returns: "castd_backup_1708700000000001_b2e5f3.db" (the safety backup)
```

**Import is destructive.** It drops every existing table and replaces
the database contents with the SQL file. A safety backup is created
automatically before the import — the returned filename identifies it.

Only `.sql` files from the `backups/` directory are accepted.

### Typical Workflow

```
Source system                    Target system
─────────────                    ─────────────
cn.db.export()
  → castd_export_...sql
                    ──transfer──→
                                 cn.db.import("castd_export_...sql")
                                   → auto-backup before import
                                   → drop all → replay SQL
```

### CLI Access

The same operations are available via the command line:

```bash
castd db backup              # Create snapshot
castd db backup --list       # List all backups
castd db backup --restore ID # Restore a backup by its unique ID
```

---

## Built-in Tables

The server creates these tables automatically on first start:

| Table | Purpose |
|-------|---------|
| `users` | User accounts (email, password_hash, role) |
| `sessions` | Session tokens with expiry |
| `permissions` | Role-based access control rules |
| `pages` | Route-to-template mapping |
| `page_content` | Structured content sections per page |
| `tenants` | Multi-tenancy support |
| `assets` | Digital asset management metadata |
| `volumes` | Volume definitions for file storage |
| `_meta` | Internal schema versioning |

Custom tables (e.g. `db.posts`, `db.products`) are created on first
`{* write *}` and extended as needed. You never need to define a schema.

---

*See [04-cast.md](04-cast.md) for the full CAST syntax specification.*
*See [12-context.md](12-context.md) for the tag-based Context system.*
