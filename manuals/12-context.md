# Context System

**Version:** 1.0  
**Status:** Active

---

## Overview

CASTD uses a tag-based context system for fast lookups, permissions, categories, and relations. Tags live in memory for instant access.

**Philosophy:** Everything is tagged. Queries are O(1).

---

## Tag Format

```
key:value
```

| Tag | Key | Value |
|-----|-----|-------|
| `status:published` | `status` | `published` |
| `author:42` | `author` | `42` |
| `category:tech` | `category` | `tech` |
| `topic:rust` | `topic` | `rust` |
| `related.post:456` | `related.post` | `456` |

**Namespaced keys** use dot-notation for hierarchy:

```
related.post:456     — Relation to post 456
related.asset:99     — Relation to asset 99
require.role:admin   — Requires admin role
```

---

## Use Cases

### Permissions

Restrict content by role or permission:

```csv
id;tags
123;status:published,require.role:admin
456;status:published,require.logged-in:true
789;status:published
```

When a user requests post 123:
1. System checks tags for `require.*`
2. Compares against user's roles/permissions
3. Allows or denies access

### Categories

System-defined categories:

```csv
id;tags
123;category:blog,category:tech
456;category:news
```

### Free Tagging

User-defined tags for flexible organisation:

```csv
id;tags
123;topic:rust,topic:webdev,topic:performance
```

### Relations

Link content together:

```csv
id;tags
123;related.post:456,related.post:789
456;related.post:123
```

---

## Query Types

All queries are O(1):

| Query | Meaning |
|-------|---------|
| `author:42` | Exact match |
| `author:*` | All with any author |
| `*:42` | All referencing 42 |
| `related.post:*` | All with any post relation |

**Combined queries (AND):**

Multiple tags filter with AND logic:

```html
{* read db.posts | context status:published, topic:rust *}
```

This finds posts that are BOTH published AND tagged with rust.

---

## Template Syntax

### Context Filter

Filter database queries via context tags:

```html
{* read db.posts | context status:published, topic:rust *}
  {! each items !}
    <article>{{ item.title }}</article>
  {! end !}
{* end *}
```

### Combined with SQL

Context filters combine with standard query modifiers:

```html
{* read db.posts | context status:published, topic:rust | where views > 100 | order=created desc *}
```

1. Context filters: `status:published` AND `topic:rust`
2. SQLite: `WHERE ... AND views > 100 ORDER BY created DESC`

### Automatic Permission Checks

When content has `require.*` tags, the system automatically:
1. Checks against current user
2. Filters out forbidden items
3. Returns only accessible content

---

## System Tags

Reserved tag keys:

| Key | Purpose | Example |
|-----|---------|---------|
| `status` | Publication state | `status:published`, `status:draft` |
| `author` | Creator reference | `author:42` |
| `created` | Creation timestamp | `created:1705484400` |
| `updated` | Last modification | `updated:1705484500` |
| `require.role` | Role requirement | `require.role:admin` |
| `require.permission` | Permission requirement | `require.permission:edit` |
| `require.logged-in` | Login requirement | `require.logged-in:true` |
| `category` | Fixed category | `category:blog` |
| `related.post` | Relation to post | `related.post:456` |
| `related.asset` | Relation to asset | `related.asset:99` |
| `related.user` | Relation to user | `related.user:42` |
| `theme` | Theme configuration | `theme:dark-corporate` |

User-defined tags can use any other key.

---

## Persistence

### CSV Format

Tags are stored in CSV files:

```csv
id;tags
123;status:published,author:42,category:tech,topic:rust
456;status:draft,author:42,category:tech
```

- `id` — Entity ID
- `tags` — Comma-separated `key:value` pairs

### Data Directory

```
data/
├── castd.db    (SQLite — Content)
└── context/         (Tag Index — CSV)
    ├── posts.csv
    ├── pages.csv
    ├── users.csv
    └── assets.csv
```

---

## Cross-Type Relations

Tags can reference entities across types:

```csv
# posts.csv
id;tags
123;author:42,related.asset:99

# users.csv  
id;tags
42;role:admin,authored.post:123

# assets.csv
id;tags
99;used-in.post:123
```

This enables:
- Find all posts by author 42
- Find all posts using asset 99
- Find all assets used in post 123

---

## Theme Configuration

Bundles use context tags for theme layering:

```csv
id;tags
1;theme:dark-corporate,preset.button:rounded
```

The server reads these tags and applies the appropriate theme files.

---

## Performance

| Operation | Complexity |
|-----------|------------|
| Tag lookup | O(1) |
| Wildcard query | O(1) |
| AND query | O(n × m) |
| Add/remove tag | O(1) |

All lookups are instant via in-memory hash maps.

---

## See Also

- **Template syntax:** See [04-cast.md](04-cast.md)
- **Persistence:** See [11-persistence.md](11-persistence.md)

---

*Copyright 2025 Vivian Voss. Apache-2.0*
