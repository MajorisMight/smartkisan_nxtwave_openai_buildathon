// Import Supabase Client
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { load } from 'https://deno.land/std@0.224.0/dotenv/mod.ts'

// Replace lines 5-7 with this:
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? '';

Deno.serve(async (req) => {
  // 1. Parse the Webhook Payload
  const payload = await req.json()
  const post = payload.record // The row inserted into 'posts' table

  // 2. Safety Check: Only run if it's a "pest" tag
  // Adjust this based on how you store tags. If it's a simple text array:
  if (!post.tags || !post.tags.includes('pest')) {
    console.log("Not a pest outbreak. Skipping.")
    return new Response('Skipped', { status: 200 })
  }

  // 3. Setup Supabase Admin Client
  // We need this to bypass RLS and read all users' emails
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // 4. Extract Location
  // We assume 'posts' has a 'location' column (Geography). 
  // However, the webhook payload sends it as a hex string usually.
  // A simpler trick: We pass the RAW latitude/longitude from the app 
  // into separate columns in 'posts' table (e.g., lat, long) for easy reading here.
  // OR we use the 'get_users_near_outbreak' RPC which handles the point logic.
  
  // *Crucial*: Ensure your 'posts' table has 'latitude' and 'longitude' columns
  // populated by your Flutter app for this to work easily.
  const lat = post.latitude
  const long = post.longitude

  if (!lat || !long) {
    return new Response('Missing location data in post', { status: 400 })
  }

  // 5. Find Users (Calling the SQL Function)
  const { data: farmers, error } = await supabase.rpc('get_users_near_outbreak', {
    lat: lat,
    long: long,
    radius_km: 10 // Alert farmers within 10km
  })

  if (error) {
    console.error("RPC Error:", error)
    return new Response('Error finding farmers', { status: 500 })
  }

  if (!farmers || farmers.length === 0) {
    return new Response('No farmers nearby to alert.', { status: 200 })
  }

  console.log(`Found ${farmers.length} farmers to alert.`)

  // 6. Send Emails via Resend
  const emailPromises = farmers.map(async (farmer: any) => {
    // LOGGING: See which farmer we are trying to alert
    console.log(`Attempting to alert farmer: ${farmer.email}`);

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        // RESTRICTION: Use the exact onboarding address for unverified domains
        from: 'onboarding@resend.dev', 
        to: [farmer.email],
        subject: `⚠️ Pest Alert in your Area!`,
        html: `<h1>Pest Outbreak Detected</h1><p>Post: ${post.title}</p>`,
      }),
    });

    // LOGGING: Capture the actual error message from Resend
    const responseData = await res.json();
    if (!res.ok) {
      console.error(`Resend Error for ${farmer.email}:`, JSON.stringify(responseData));
    } else {
      console.log(`Email sent successfully to ${farmer.email}`);
    }
    return responseData;
  });

  await Promise.all(emailPromises);
  
  return new Response(
    JSON.stringify({ success: true, alerted: farmers.length }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
