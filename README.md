# EmDash Starter Template (Cloudflare)

A general-purpose starting point for building sites with [EmDash](https://github.com/emdash-cms/emdash) on Cloudflare Workers. Includes posts, pages, categories, and tags, styled with **tinywind** -- a super minimal Tailwind CSS theme -- designed as a base you can build on rather than a finished design.

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
- **tinywind** theme -- Tailwind CSS, dark/light mode support

## Theme: tinywind

The whole theme lives in [`src/styles/tinywind.css`](src/styles/tinywind.css) (a single `@import "tailwindcss"` plus a couple of base rules) -- everything else is Tailwind utility classes on the components in `src/layouts/` and `src/pages/`. There's no design-token layer, component library, or build step beyond Tailwind itself:

- One column, `max-w-2xl`, generous whitespace, system font stack -- no custom fonts to load.
- Grayscale (Tailwind's `neutral` palette) with no accent color.
- Dark mode follows the OS-level `prefers-color-scheme` automatically via Tailwind's `dark:` variant -- no toggle/JS required.
- Rich text (`PortableText` output) is wrapped in `prose dark:prose-invert` from `@tailwindcss/typography` for readable defaults; everything else uses plain utility classes.

To restyle: edit classes directly in the `.astro` files, or extend the design tokens with an `@theme` block in `tinywind.css` (see the [Tailwind v4 docs](https://tailwindcss.com/docs/theme)). `src/components/PostCard.astro` is the one shared component -- it's reused by the homepage, `/posts`, category, and tag archives, so styling changes there apply everywhere post listings appear.

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

Before your first deploy, push the runtime encryption secret to the Worker (the value already sitting in your local `.env` as `EMDASH_ENCRYPTION_KEY` -- generate a new one instead if this is a real production site):

```bash
wrangler secret put EMDASH_ENCRYPTION_KEY
```

## CI/CD (Optional)

This repo ships with two *inactive* example workflows in `.github/workflows/` (the `.yml.example` suffix keeps GitHub Actions from picking them up):

- **`ci.yml.example`** -- installs deps, runs `pnpm typecheck` and `pnpm build` on every push and pull request. Needs no secrets.
- **`deploy.yml.example`** -- runs `pnpm build && wrangler deploy` on every push to `main`. Needs the two repo secrets below.

To enable either one:

```bash
cp .github/workflows/ci.yml.example .github/workflows/ci.yml
cp .github/workflows/deploy.yml.example .github/workflows/deploy.yml
git add .github/workflows/*.yml && git commit -m "Enable CI/CD"
```

For `deploy.yml`, add these under the repo's **Settings → Secrets and variables → Actions**:

| Secret | How to get it |
|---|---|
| `CLOUDFLARE_API_TOKEN` | Cloudflare dashboard → My Profile → API Tokens → Create Token, using the "Edit Cloudflare Workers" template (needs Workers Scripts, D1, and R2 edit permissions for this project's account/zone). |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare dashboard → Workers & Pages → Overview (right sidebar), or `wrangler whoami`. |

These CI secrets only authenticate the *deploy* -- they're separate from the `EMDASH_ENCRYPTION_KEY` runtime secret above, which is set once directly on the Worker via `wrangler secret put` and isn't touched by CI.

## See Also

- [EmDash repository](https://github.com/emdash-cms/emdash)
- [EmDash documentation](https://github.com/emdash-cms/emdash/tree/main/docs)
