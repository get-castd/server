# File Volumes

> Named, sandboxed directories for file storage. Configured in
> `server.toml`, stored on disc, filenames in the database as plain text.
> No external dependencies.

---

## Configuration

Volumes are defined in `server.toml`. Two forms are available.

### Simple

```toml
[volumes]
uploads = "/var/data/uploads"
```

Path only. No size limit, no type restriction.

### Extended

```toml
[volumes.uploads]
path = "/var/data/uploads"
max_size = "10MB"
allowed_types = ["image/jpeg", "image/png", "image/webp"]
```

| Key | Required | Description |
|-----|----------|-------------|
| `path` | Yes | Absolute path to directory |
| `max_size` | No | Human-readable limit: `KB`, `MB`, `GB` |
| `allowed_types` | No | MIME type whitelist (empty = accept all) |

**Rules:**

- Paths must be absolute — no `..` permitted
- Directories are created automatically on startup
- Volume names must be valid identifiers (alphanumeric, underscores)

---

## Uploading Files

Add `volume="name"` to a file input inside a `{* write *}` block:

```html
{* write db.products *}
<form method="post" enctype="multipart/form-data">
    <input type="text" name="title">
    <input type="file" name="photo" volume="uploads">
    <button type="submit">Save</button>
</form>
{* endwrite *}
```

On POST:

1. The file is saved to the volume directory
2. The generated filename is stored in the `photo` column
3. Text fields go straight to their columns

**Filename format:** `{timestamp}_{uid}_{original}`

The combination of timestamp, unique identifier, and original name
guarantees collision-free storage. No two uploads produce the same
filename.

---

## Template Variables

Each volume exposes its serving path:

```
{{ volumes.uploads }}  →  /volumes/uploads
```

Use in templates:

```html
{* read db.products *}
  {! each items !}
    <img src="{{ volumes.uploads }}/{{ item.photo }}" alt="{{ item.title }}">
  {! endeach !}
{* endread *}
```

---

## Serving Files

Files are served at `/volumes/{name}/{file}`.

| Behaviour | Detail |
|-----------|--------|
| Methods | GET and HEAD only |
| Content-Type | Detected automatically |
| Disposition | Images and PDFs inline; everything else as attachment |
| Caching | `Cache-Control: immutable` — filenames are unique |

No configuration needed. The route exists as soon as the volume is
defined in `server.toml`.

---

## Validation

Every upload passes four checks before touching the disc:

| Check | Rejection |
|-------|-----------|
| File size | Exceeds `max_size` |
| MIME type | Not in `allowed_types` |
| Path traversal | Contains `..` or null bytes |
| Filename | Sanitised to lowercase, safe characters only |

Validation runs server-side. Client-side `accept` attributes are
cosmetic — the server enforces the rules regardless.

---

## Cleanup

Orphan files — present on disc but absent from the database — accumulate
when records are deleted. The CLI provides a cleanup command:

```bash
castd db cleanup-volumes           # Dry run: lists orphans
castd db cleanup-volumes --confirm # Deletes orphan files
```

Run the dry run first. Always.

---

## Feedback Variables

After a POST that includes a file upload, these variables are available
in the template:

| Variable | Type | Content |
|----------|------|---------|
| `success` | Boolean | Whether the operation succeeded |
| `id` | Integer | Inserted row ID |
| `error` | String | Error message (if failed) |

```html
{* write db.products *}
  {! if error !}
    <p class="error">{{ error }}</p>
  {! endif !}
  {! if success !}
    {{ redirect = "/products/" .. id }}
  {! endif !}

  <form method="post" enctype="multipart/form-data">
    <input type="text" name="title" required>
    <input type="file" name="photo" volume="uploads">
    <button type="submit">Save</button>
  </form>
{* endwrite *}
```

---

## Complete Example: Product Catalogue

**`server.toml`:**

```toml
[volumes.uploads]
path = "/var/data/uploads"
max_size = "10MB"
allowed_types = ["image/jpeg", "image/png", "image/webp"]
```

**`templates/products/index.html`** — List products:

```html
<h1>Products</h1>

{* read db.products | order=created desc *}
  {! each items !}
    <article>
      <img src="{{ volumes.uploads }}/{{ item.photo }}" alt="{{ item.title }}">
      <h2>{{ item.title }}</h2>
    </article>
  {! endeach !}
{* endread *}

{* require role="editor" *}
  <a href="/products/new">Add Product</a>
{* endrequire *}
```

**`templates/products/new.html`** — Upload form (protected):

```html
{* require role="editor" *}
  {* write db.products *}
    {! if error !}
      <p class="error">{{ error }}</p>
    {! endif !}
    {! if success !}
      {{ redirect = "/products" }}
    {! endif !}

    <h1>New Product</h1>
    <form method="post" enctype="multipart/form-data">
      <input type="text" name="title" required>
      <input type="file" name="photo" volume="uploads" accept="image/*">
      <button type="submit">Save</button>
    </form>
  {* endwrite *}
{* endrequire *}
```

---

*See [11-persistence.md](11-persistence.md) for the full persistence specification.*

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
