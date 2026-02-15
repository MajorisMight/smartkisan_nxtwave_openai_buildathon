import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const { old_record } = await req.json()
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // 1. Identify all potential image fields from the deleted row
    const rawUrls = [
      old_record.photo_url,        // From 'farmers' table
      ...(old_record.image_urls || []) // From 'posts' table array
    ].filter(Boolean) // Remove null/undefined

    if (rawUrls.length === 0) return new Response('No files to delete', { status: 200 })

    const deletionResults = await Promise.all(
      rawUrls.map(async (url) => {
        // 2. Cleanly extract bucket and path
        // URL format: .../storage/v1/object/public/[bucket]/[folder]/[file]
        const parts = url.split('/storage/v1/object/public/')[1]?.split('/')
        if (!parts || parts.length < 2) return { url, status: 'invalid format' }

        const bucket = parts[0]
        const path = parts.slice(1).join('/')

        const { error } = await supabase.storage.from(bucket).remove([path])
        return { path, status: error ? 'error' : 'success', error }
      })
    )

    console.log('Deletion results:', deletionResults)
    return new Response(JSON.stringify(deletionResults), { 
      status: 200, 
      headers: { 'Content-Type': 'application/json' } 
    })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})