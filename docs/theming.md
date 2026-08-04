# Customizing tinywind

tinywind is deliberately thin: one stylesheet ([`src/styles/tinywind.css`](../src/styles/tinywind.css)) that imports Tailwind, plus plain Tailwind utility classes written directly on the `.astro` files in [`src/layouts/`](../src/layouts/) and [`src/pages/`](../src/pages/). There's no theme config object, no component library, and no build step beyond Tailwind's own Vite plugin. Every example below was written against the exact versions pinned in this repo's `package.json` and verified with a real `pnpm build`.

- [Colors and design tokens](#colors-and-design-tokens)
- [Layout width and spacing](#layout-width-and-spacing)
- [Typography and prose content](#typography-and-prose-content)
- [Custom fonts](#custom-fonts)
- [Manual dark-mode toggle](#manual-dark-mode-toggle)
- [Adding a Tailwind plugin](#adding-a-tailwind-plugin)
- [Extending components](#extending-components)

## Colors and design tokens

Tailwind v4 is CSS-first: there's no `tailwind.config.js`. New design tokens go in an `@theme` block in `tinywind.css`, and Tailwind generates matching utilities (`text-*`, `bg-*`, `border-*`, `ring-*`, ...) automatically.

To add an accent color:

```css
/* src/styles/tinywind.css */
@import "tailwindcss";
@plugin "@tailwindcss/typography";

@theme {
	--color-accent: oklch(0.55 0.2 260); /* a blue; pick any color */
}
```

```astro
<a href="/" class="text-accent hover:underline">Go home</a>
```

This generates `text-accent`, `bg-accent`, `border-accent`, `decoration-accent`, etc. -- the same way any other Tailwind color does. To replace the whole neutral palette instead of adding one color on top of it, override the `--color-neutral-*` scale the same way (see the [Tailwind theme docs](https://tailwindcss.com/docs/theme) for the full token list).

## Layout width and spacing

The single-column width comes from one class, repeated on `<nav>`, `<main>`, `<footer>`'s inner wrapper, and the nav/footer content -- see [`src/layouts/Base.astro`](../src/layouts/Base.astro):

```astro
<main class="mx-auto w-full max-w-2xl flex-1 px-4 py-10">
```

Widen the site by changing `max-w-2xl` to `max-w-3xl` (or `max-w-4xl`, etc.) in all four places it appears in `Base.astro`. Vertical rhythm (`py-10`, `py-5`, `py-8`) and the post-list spacing in [`src/components/PostCard.astro`](../src/components/PostCard.astro) can be adjusted the same way -- they're just utility classes, not a shared spacing config.

## Typography and prose content

Post and page bodies (rendered via `PortableText`) are wrapped in the [`@tailwindcss/typography`](https://github.com/tailwindlabs/tailwindcss-typography) plugin's `prose` class:

```astro
<!-- src/pages/posts/[slug].astro and src/pages/[slug].astro -->
<div class="prose prose-neutral mt-8 max-w-none dark:prose-invert">
	<PortableText value={post.data.content} />
</div>
```

Target individual elements inside prose content with `prose-{element}:{utility}` modifiers, right on that same class list:

```astro
<div class="prose prose-neutral mt-8 max-w-none dark:prose-invert prose-a:text-accent prose-blockquote:not-italic">
```

That example recolors in-content links to the `accent` token from above and removes the default italic styling from blockquotes. Any Typography-plugin element (`prose-headings`, `prose-code`, `prose-img`, `prose-li`, ...) works the same way.

## Custom fonts

tinywind ships with no custom fonts -- just the system font stack -- to avoid a network request. To add one, use [Astro's built-in font support](https://docs.astro.build/en/guides/fonts/) (stable as of Astro 6) rather than a separate webfont package:

```js
// astro.config.mjs
import { defineConfig, fontProviders } from "astro/config";

export default defineConfig({
	// ...existing config
	fonts: [
		{
			provider: fontProviders.google(),
			name: "Inter",
			cssVariable: "--font-inter",
		},
	],
});
```

```astro
---
// src/layouts/Base.astro
import { Font } from "astro:assets";
---
<head>
	<!-- ...existing head content -->
	<Font cssVariable="--font-inter" preload />
</head>
```

Then point Tailwind's `font-sans` token at the loaded font, with the original stack as fallback:

```css
/* src/styles/tinywind.css */
@theme {
	--font-sans: var(--font-inter), ui-sans-serif, system-ui, sans-serif;
}
```

No component needs a `font-inter` class -- `--font-sans` is already the default font for the whole page.

## Manual dark-mode toggle

By default, dark mode follows the OS-level `prefers-color-scheme` automatically -- Tailwind v4's `dark:` variant does this out of the box, no JS required. To switch to a toggle the visitor controls, swap the variant's strategy from media-query-based to class-based:

```css
/* src/styles/tinywind.css -- add this line after the @plugin line */
@custom-variant dark (&:where(.dark, .dark *));
```

Every `dark:` utility already in the theme keeps working unchanged -- only the trigger changes, from "OS preference" to "does `.dark` appear on an ancestor". Add a small inline script to `Base.astro`'s `<head>` (inline so it runs before first paint and there's no flash of the wrong theme) and a toggle button in the nav:

```astro
<head>
	<!-- ...existing head content -->
	<script is:inline>
		document.documentElement.classList.toggle(
			"dark",
			localStorage.theme === "dark" ||
				(!("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches),
		);
	</script>
</head>
```

```astro
<button
	type="button"
	class="no-underline"
	onclick="const isDark = document.documentElement.classList.toggle('dark'); localStorage.theme = isDark ? 'dark' : 'light';"
>
	Toggle theme
</button>
```

## Adding a Tailwind plugin

`@tailwindcss/typography` is already wired in as the one example of a plugin. Adding another (e.g. [`@tailwindcss/forms`](https://github.com/tailwindlabs/tailwindcss-forms), useful if you build out `CommentForm` from `emdash/ui`) is two steps:

```bash
pnpm add -D @tailwindcss/forms
```

```css
/* src/styles/tinywind.css */
@import "tailwindcss";
@plugin "@tailwindcss/typography";
@plugin "@tailwindcss/forms";
```

## Extending components

[`src/components/PostCard.astro`](../src/components/PostCard.astro) is the one shared component -- the homepage, `/posts`, category archives, and tag archives all render it, so a change there applies everywhere post listings appear. It's a plain `.astro` component with a typed `Props` interface; treat it as the template for any new component (an `Avatar`, a `Byline`, a pagination control, ...):

1. Create `src/components/YourComponent.astro` with a `Props` interface matching the shape of data you'll pass in (check `emdash-env.d.ts` for the generated field types, as `PostCard` does for `featured_image`).
2. Write markup with plain Tailwind utility classes -- no wrapper library or `class-variance-authority`-style helper is set up, and for a theme this small it isn't needed.
3. Import and use it from whichever page(s) need it, the same way `index.astro`, `posts/index.astro`, `category/[slug].astro`, and `tag/[slug].astro` all import `PostCard`.

For anything that needs to appear on every page (a byline, a "back to top" link), add it directly to `Base.astro` instead of creating a new layout -- there's only one layout in this starter, and that's intentional.
