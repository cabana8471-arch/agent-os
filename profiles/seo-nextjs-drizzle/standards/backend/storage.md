# File Storage Standards - Vercel Blob

This standard documents file storage and management patterns using Vercel Blob for the SEO Optimization application.

## I. Installation & Setup

### Install Dependencies

```bash
pnpm install @vercel/blob
```

### Environment Variables

```bash
BLOB_READ_WRITE_TOKEN=
```

---

## II. Upload Files

### Basic File Upload

```typescript
// app/api/reports/export/route.ts
import { put } from '@vercel/blob'
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/lib/auth'

export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const formData = await request.formData()
    const file = formData.get('file') as File

    if (!file) {
      return NextResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      )
    }

    // Upload to Vercel Blob
    const blob = await put(`reports/${crypto.randomUUID()}.pdf`, file, {
      access: 'public',
      addRandomSuffix: false,
    })

    return NextResponse.json({
      url: blob.url,
      size: blob.size,
      contentType: blob.contentType,
    })
  } catch (error) {
    console.error('Upload failed:', error)
    return NextResponse.json(
      { error: 'Upload failed' },
      { status: 500 }
    )
  }
}
```

### Upload with Metadata

```typescript
// app/api/uploads/route.ts
import { put } from '@vercel/blob'

export async function POST(request: NextRequest) {
  const formData = await request.formData()
  const file = formData.get('file') as File
  const projectId = formData.get('projectId') as string

  const blob = await put(`uploads/${projectId}/${file.name}`, file, {
    access: 'public',
    addRandomSuffix: true,
    metadata: {
      uploadedBy: session.user.id,
      uploadedAt: new Date().toISOString(),
      projectId: projectId,
    },
  })

  return NextResponse.json(blob)
}
```

### Streaming Upload

```typescript
// For large files
import { put } from '@vercel/blob'

export async function POST(request: NextRequest) {
  const stream = request.body!

  const blob = await put('large-file.pdf', stream, {
    access: 'public',
    contentType: 'application/pdf',
  })

  return NextResponse.json(blob)
}
```

---

## III. List Files

### List Files in Prefix

```typescript
// app/api/reports/list/route.ts
import { list } from '@vercel/blob'

export async function GET() {
  const { blobs } = await list({
    prefix: 'reports/',
    limit: 100,
  })

  return Response.json({
    reports: blobs.map(blob => ({
      url: blob.url,
      pathname: blob.pathname,
      size: blob.size,
      uploadedAt: blob.uploadedAt,
    })),
  })
}
```

### Pagination

```typescript
import { list } from '@vercel/blob'

export async function GET(request: NextRequest) {
  const cursor = request.nextUrl.searchParams.get('cursor')

  const { blobs, cursor: nextCursor } = await list({
    prefix: 'reports/',
    limit: 20,
    cursor,
  })

  return Response.json({
    blobs,
    nextCursor,
    hasMore: nextCursor !== undefined,
  })
}
```

---

## IV. Download Files

### Stream File Response

```typescript
// app/api/download/route.ts
import { download } from '@vercel/blob'

export async function GET(request: NextRequest) {
  const url = request.nextUrl.searchParams.get('url')

  if (!url) {
    return new Response('URL required', { status: 400 })
  }

  const blob = await download(url)

  return new Response(blob, {
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': 'attachment; filename="report.pdf"',
    },
  })
}
```

---

## V. Delete Files

### Delete Single File

```typescript
// app/api/reports/[id]/delete/route.ts
import { del } from '@vercel/blob'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const { url } = await request.json()

    // Verify ownership before deleting
    // Check database record for permission

    await del(url)

    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { error: 'Delete failed' },
      { status: 500 }
    )
  }
}
```

### Delete Multiple Files

```typescript
import { del } from '@vercel/blob'

export async function POST(request: NextRequest) {
  const { urls } = await request.json()

  await Promise.all(urls.map(url => del(url)))

  return NextResponse.json({ deleted: urls.length })
}
```

---

## VI. Report Generation

### Generate and Upload PDF Report

```typescript
// app/api/projects/[id]/export/route.ts
import { put } from '@vercel/blob'
import { generatePDF } from '@/lib/pdf-generator'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    // Fetch project data
    const project = await db.query.project.findFirst({
      where: and(
        eq(projectTable.id, params.id),
        eq(projectTable.userId, session.user.id)
      ),
      with: {
        scannedPages: {
          with: {
            recommendations: true,
          },
        },
      },
    })

    if (!project) {
      return NextResponse.json(
        { error: 'Project not found' },
        { status: 404 }
      )
    }

    // Generate PDF
    const pdfBuffer = await generatePDF({
      projectName: project.name,
      pages: project.scannedPages,
    })

    // Upload to Blob
    const blob = await put(
      `reports/${project.id}/${crypto.randomUUID()}.pdf`,
      pdfBuffer,
      {
        access: 'public',
        contentType: 'application/pdf',
      }
    )

    // Save to database
    await db.insert(report).values({
      id: crypto.randomUUID(),
      projectId: project.id,
      userId: session.user.id,
      url: blob.url,
      filename: `${project.name}-report.pdf`,
      fileSize: blob.size,
    })

    return NextResponse.json({
      url: blob.url,
      filename: `${project.name}-report.pdf`,
    })
  } catch (error) {
    console.error('Report generation failed:', error)
    return NextResponse.json(
      { error: 'Report generation failed' },
      { status: 500 }
    )
  }
}
```

### Generate CSV Export

```typescript
import { put } from '@vercel/blob'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    // Fetch project data
    const project = await db.query.project.findFirst({
      where: and(
        eq(projectTable.id, params.id),
        eq(projectTable.userId, session.user.id)
      ),
      with: {
        scannedPages: true,
      },
    })

    // Generate CSV
    const csv = generateCSV({
      projectName: project.name,
      pages: project.scannedPages,
    })

    // Upload to Blob
    const blob = await put(
      `exports/${project.id}/${crypto.randomUUID()}.csv`,
      csv,
      {
        access: 'public',
        contentType: 'text/csv',
      }
    )

    return NextResponse.json({
      url: blob.url,
      format: 'csv',
    })
  } catch (error) {
    return NextResponse.json(
      { error: 'Export failed' },
      { status: 500 }
    )
  }
}
```

---

## VII. Client-Side Upload

### File Input Component

```typescript
// app/components/file-upload.tsx
'use client'

import { useState } from 'react'
import { toast } from 'sonner'

export function FileUpload({ projectId }: { projectId: string }) {
  const [uploading, setUploading] = useState(false)

  async function handleUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    setUploading(true)

    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('projectId', projectId)

      const response = await fetch('/api/uploads', {
        method: 'POST',
        body: formData,
      })

      if (!response.ok) throw new Error('Upload failed')

      const { url } = await response.json()
      toast.success('File uploaded')
      // Use the file URL...
    } catch (error) {
      toast.error('Upload failed')
    } finally {
      setUploading(false)
    }
  }

  return (
    <div>
      <input
        type="file"
        onChange={handleUpload}
        disabled={uploading}
      />
      {uploading && <p>Uploading...</p>}
    </div>
  )
}
```

### Download Button

```typescript
// app/components/download-button.tsx
'use client'

import { useState } from 'react'

export function DownloadButton({ url, filename }: { url: string; filename: string }) {
  const [downloading, setDownloading] = useState(false)

  async function handleDownload() {
    setDownloading(true)

    try {
      const response = await fetch(`/api/download?url=${encodeURIComponent(url)}`)
      const blob = await response.blob()

      // Create download link
      const downloadUrl = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = downloadUrl
      link.download = filename
      link.click()

      window.URL.revokeObjectURL(downloadUrl)
    } finally {
      setDownloading(false)
    }
  }

  return (
    <button onClick={handleDownload} disabled={downloading}>
      {downloading ? 'Downloading...' : 'Download'}
    </button>
  )
}
```

---

## VIII. Use Cases

### Report Generation
```typescript
// Store PDF reports for later access
const reportUrl = await generateAndUploadReport(projectId)
```

### File Uploads
```typescript
// Accept user file uploads
const uploadUrl = await uploadUserFile(file, projectId)
```

### Temporary Files
```typescript
// Store temporary processing files
const tempUrl = await uploadTempFile(data)
// Delete after 1 hour
```

### Asset Hosting
```typescript
// Host images and static assets
const assetUrl = await uploadAsset(image)
```

---

## IX. Best Practices

1. **Use prefixes for organization** - `reports/`, `uploads/`, `exports/`
2. **Set access levels appropriately** - Public vs private files
3. **Generate unique filenames** - Use UUIDs to avoid conflicts
4. **Validate file types** - Check MIME type on upload
5. **Limit file sizes** - Enforce maximum file size
6. **Clean up old files** - Implement lifecycle management
7. **Store metadata** - Track file ownership and creation time
8. **Use content types** - Set correct MIME type
9. **Add random suffixes** - Avoid collisions with `addRandomSuffix`
10. **Track in database** - Store file references for ownership/deletion

---

## X. Database Schema for Files

```typescript
// src/db/schema/file.ts
import { pgTable, text, varchar, timestamp, bigint } from 'drizzle-orm/pg-core'

export const report = pgTable('report', {
  id: text('id').primaryKey(),
  projectId: text('project_id').notNull().references(() => project.id, { onDelete: 'cascade' }),
  userId: text('user_id').notNull().references(() => user.id, { onDelete: 'cascade' }),
  url: text('url').notNull(),
  filename: varchar('filename').notNull(),
  fileSize: bigint('file_size'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
})

export type Report = InferSelectModel<typeof report>
export type NewReport = InferInsertModel<typeof report>
```

---

## Related Standards

- {{standards/backend/api}} - Uploading from route handlers
- {{standards/backend/background-jobs}} - Generating files in jobs
- {{standards/global/error-handling}} - Upload error handling
