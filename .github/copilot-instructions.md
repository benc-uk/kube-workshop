# Copilot Instructions — kube-workshop

## Project Overview

An Eleventy v3 static site generating a hands-on Kubernetes (AKS) workshop. Content is authored in Markdown under `content/`, built to `_site/`, and deployed to GitHub Pages. The workshop walks developers through deploying a multi-tier app (Postgres → API → Frontend) on AKS.

The intent of this project is to provide a comprehensive, step-by-step learning experience for developers new to Kubernetes, with a focus on practical application and real-world scenarios. The content is structured into sections that cover everything from cluster setup to advanced operations, with a mix of explanations, code snippets, and exercises.

## Build & Dev Commands

- `npm start` — dev server with hot reload at `http://localhost:8080`
- `npm run build` — production build to `_site/`
- `npm run lint` — auto-format Markdown with Prettier (`--write`)
- `npm run lint:check` — CI formatting check (runs in GitHub Actions)
- `npm run clean` — remove `_site/`

## Content Authoring

### Frontmatter (required on every section page)

```yaml
---
tags: section # "section" (main flow 00–09), "extra" (bonus 10–12), or "alternative" (e.g. 09a)
index: 4 # Numeric order, matches directory prefix
title: Deploying The Backend
summary: One-line description for the home page listing
layout: default.njk # Always this value
icon: 🚀 # Single emoji shown in sidebar and headings
---
```

### Directory & File Conventions

- Section directories: `content/{NN}-{slug}/index.md` (zero-padded two-digit prefix)
- Supporting files (YAML manifests, `.sql`, `.png`, `.sh`, `.svg`) go alongside `index.md` — Eleventy copies them via passthrough
- YAML manifests use `__ACR_NAME__` as a user-replaceable placeholder
- The home page `content/index.md` has only `title` and `layout` (no tags/index/icon/summary)

### Content Patterns

- Raw HTML is enabled in Markdown (`html: true` in markdown-it config)
- Use `<details>`/`<summary>` for collapsible solution/cheat blocks containing YAML code
- Use `markdown-it-attrs` syntax (`{.class #id}`) for adding attributes to elements
- External links auto-open in new tabs (custom markdown-it plugin)
- Prefix external doc links with 📚 emoji, e.g. `[📚 Kubernetes Docs: Deployments](...)`
- Use emojis as sub-section visual markers (🔨, 🧪, 🌡️, etc.)
- Prettier config: 120-char width, `proseWrap: "always"` — run `npm run lint` before committing

### Navigation

- `tags: section` pages get automatic prev/next links and appear in sidebar
- `tags: extra` pages appear in a separate sidebar group below a divider
- `tags: alternative` pages are not auto-listed — link to them manually from related sections

## Key Files

- `eleventy.config.js` — Eleventy plugins (syntax highlight, markdown-it-attrs), passthrough copy rules, custom filters (`zeroPad`, `cssmin`), external links plugin
- `content/_includes/default.njk` — Single layout template with sidebar nav, theme toggle, prev/next footer
- `content/_includes/main.css` / `main.js` — Inlined (not linked) into the template via Nunjucks `{% include %}` + `cssmin` filter
- `content/.prettierrc` — Prettier config (`printWidth: 120`, `proseWrap: "always"`)
- `gitops/` — Kustomize manifests used by the GitOps/Flux section (section 11); contains `base/`, `apps/`, `disabled/` directories

## CI/CD

Single workflow `.github/workflows/ci-build-deploy.yaml`:

1. **lint** job — `npm run lint:check` on all pushes/PRs to `main`
2. **deploy** job — builds site and deploys to GitHub Pages (only on `main` branch)

## Gotchas

- Never edit files in `_site/` — it's a generated output directory
- The `archive/k3s/` directory contains a deprecated K3S workshop path — don't update it
- Collections are sorted by `index` field, not directory name — keep them in sync
- CSS/JS are inlined into the HTML template, not served as separate static files
