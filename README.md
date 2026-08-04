# EmDash Starter Template (Cloudflare)

A general-purpose starting point for building sites with [EmDash](https://github.com/emdash-cms/emdash) on Cloudflare Workers. Includes posts, pages, categories, and tags with minimal styling -- designed as a base you can build on rather than a finished theme.

This repo is meant to be **forked or copied per project**: clone/duplicate it for each new site, rename it (see below), provision its own Cloudflare resources, and deploy.

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/emdash-cms/templates/tree/main/starter-cloudflare)

## Prerequisites

- Node.js `22.13+` (pinned in `.nvmrc`; run `nvm use`) and pnpm, matched to the version pinned in `package.json`'s `packageManager` field. If your system `pnpm` resolves to an older version, run installs/scripts through corepack instead: `corepack pnpm install`.
- A Cloudflare account. **EmDash's plugin sandboxing uses Cloudflare's Dynamic Worker Loaders, which require a paid Workers plan ($5/mo+).** If you're on the free plan, delete the `worker_loaders` block from `wrangler.jsonc` and plugins will be disabled -- everything else works fine.

## Renaming For a New Site

Before provisioning Cloudflare resources for a new project built from this starter, update the placeholder names so they don't collide with other sites in your account:

- `name` in `package.json`
- `name`, `d1_databases[0].database_name`, and `r2_buckets[0].bucket_name` in `wrangler.jsonc`

## What's Included

- Posts with category and tag archives
- Static pages via slug routing
- Seed data with demo content
- D1 database and R2 storage pre-configured
- Dark/light mode support

## Pages

| Page | Route |
|---|---|
| Homepage | `/` |
| All posts | `/posts` |
| Single post | `/posts/:slug` |
| Category archive | `/category/:slug` |
| Tag archive | `/tag/:slug` |
| Static pages | `/:slug` |
| 404 | fallback |

## Infrastructure

- **Runtime:** Cloudflare Workers
- **Database:** D1
- **Storage:** R2
- **Framework:** Astro with `@astrojs/cloudflare`

## Local Development

```bash
pnpm install
pnpm dev
```

`pnpm dev` applies the schema/settings from `seed/seed.json` to a local D1 emulation automatically -- no separate init step needed. The admin UI is at `http://localhost:4321/_emdash/admin`.

## Provisioning Cloudflare Resources

Once you've [renamed the project](#renaming-for-a-new-site), create its D1 database and R2 bucket, then paste the returned IDs into `wrangler.jsonc`:

```bash
wrangler login
wrangler d1 create <your-database-name>       # paste database_id into wrangler.jsonc
wrangler r2 bucket create <your-bucket-name>
```

## Deploying

```bash
pnpm deploy
```

This runs `astro build && wrangler deploy`. Alternatively, click the deploy button above to provision resources and deploy in one step via the Cloudflare dashboard.

## See Also

- [EmDash repository](https://github.com/emdash-cms/emdash)
- [EmDash documentation](https://github.com/emdash-cms/emdash/tree/main/docs)
