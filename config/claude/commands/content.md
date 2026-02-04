# /content - Content Generation Commands

Generate marketing content for FORGE MVPs using the ContentHarness.

## Usage

```
/content <action> [options]
```

## Actions

### generate
Generate content for a specific domain/project.

```
/content generate <domain> <project> [--type TYPE] [--notion] [--auto-approve]
```

**Arguments:**
- `domain`: FORGE domain (e.g., `codeswiftr-com`)
- `project`: Project name (e.g., `interview-simulator`)

**Options:**
- `--type TYPE`: Content type (blog_posts, social_media, email_sequences, landing_copy, case_studies)
- `--notion`: Use Notion storage instead of files
- `--auto-approve`: Skip human review loop
- `--dry-run`: Preview without generating

**Examples:**
```
/content generate codeswiftr-com interview-simulator --type blog_posts
/content generate leanvibe-dev tech-debt-analyzer --type social_media --notion
```

### batch
Generate full content library for a domain.

```
/content batch <domain> [--count N] [--types TYPES]
```

**Options:**
- `--count N`: Number of pieces per type (default: 10)
- `--types TYPES`: Comma-separated content types

**Examples:**
```
/content batch codeswiftr-com --count 5
/content batch leanvibe-dev --types blog_posts,social_media
```

### status
Check generation status for a brief.

```
/content status <brief-id>
```

### approve
Mark content as approved.

```
/content approve <brief-id>
```

### publish
Push approved content to a platform.

```
/content publish <brief-id> [--platform PLATFORM]
```

**Platforms:** wordpress, linkedin, twitter, mailchimp

---

## Workflow

1. **Generate**: Create content from living-docs context
2. **Review**: Human reviews draft in file or Notion
3. **Feedback**: Add feedback to trigger revision
4. **Approve**: Mark as ready for publishing
5. **Publish**: Push to target platform

## Storage Options

### File Storage (Default)
- Briefs: `content/briefs/{brief_id}.json`
- Content: `content/output/{brief_id}.md`
- Feedback: `content/feedback/{brief_id}.txt`

### Notion Storage
Configure in CLAUDE.md:
```
NOTION_BRIEFS_DB: abc123...
NOTION_CONTENT_DB: def456...
```

Then use `--notion` flag to enable.

## Integration

This command uses:
- `forge_harness.ContentHarness` for generation
- `forge_harness.NotionContentStorage` for Notion backend
- Living-docs for project context
- PostHog for tracking
