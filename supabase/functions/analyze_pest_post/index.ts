import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
// CHANGED: Using version 0.21.0 which is stable for Deno
import { GoogleGenerativeAI } from 'https://esm.sh/@google/generative-ai@0.21.0'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

const genAI = new GoogleGenerativeAI(GEMINI_API_KEY)

// CHANGED: Using 'gemini-1.5-flash-latest' to resolve 404s
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const post = payload.record 

    // Internal safety gate
    if (!post.tags || !post.tags.includes('pest')) {
      console.log("Ignored: Post does not have the 'pest' tag.")
      return new Response('Not a pest report', { status: 200 })
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    console.log(`Analyzing post: ${post.title}`)

    // 3. Prompt Gemini for Analysis
    const prompt = `
      Analyze this agricultural post for potential pest outbreaks.
      Post Title: "${post.title}"
      Post Content: "${post.content}"
      
      Return ONLY a JSON object (no markdown, no backticks) with:
      "is_legit": boolean (true if it's a real report, false if spam/scam),
      "pest_name": string (Use a standard name like "LOCUST", "FALL ARMYWORM", "APHIDS"),
      "confidence": number (0.0 to 1.0)
    `

    let analysis; // Define outside try block for scope

    try {
        const result = await model.generateContent(prompt);
        const response = await result.response;
        let aiText = response.text();

        // Cleaning Logic
        aiText = aiText.replace(/```json|```/g, '').trim();
        const jsonStart = aiText.indexOf('{');
        const jsonEnd = aiText.lastIndexOf('}') + 1;
        
        if (jsonStart === -1 || jsonEnd === 0) {
           throw new Error("No JSON found in AI response");
        }
        
        const cleanJson = aiText.substring(jsonStart, jsonEnd);
        analysis = JSON.parse(cleanJson);
        console.log("Cleaned Analysis:", analysis);
    
    } catch (aiErr) {
        console.error("Detailed Gemini Error:", aiErr);
        return new Response(JSON.stringify({ 
            error: "AI Analysis Failed", 
            details: aiErr.message 
        }), { status: 502 });
    }

    // 4. Update the 'posts' table with AI findings
    // MOVED inside the main block to access 'analysis' variable
    const status = (analysis.is_legit && analysis.confidence > 0.7) ? 'verified' : 'rejected'
    
    await supabase
      .from('posts')
      .update({
        status: status,
        pest_detected: analysis.pest_name,
        ai_confidence: analysis.confidence
      })
      .eq('id', post.id)

    if (status === 'rejected') {
      return new Response('Post rejected by AI', { status: 200 })
    }

    // 5. Check Threshold (Count verified posts of same pest in 15km)
    const { data: count, error: countError } = await supabase.rpc('count_verified_pests', {
      check_pest_name: analysis.pest_name,
      check_lat: post.latitude,
      check_long: post.longitude,
      radius_km: 15
    })

    if (countError) throw countError

    console.log(`Verified reports for ${analysis.pest_name} in area: ${count}`)

    // 6. Threshold Met: Call the Radius Assignment Function
    if (count >= 3) {
      console.log("Outbreak confirmed. Assigning actions to nearby farms...")
      
      const taskTitle = `URGENT: ${analysis.pest_name} Outbreak`
      const taskDesc = `A confirmed outbreak of ${analysis.pest_name} has been detected within 15km of your farm. Please take immediate protective measures.`

      const { error: rpcError } = await supabase.rpc('assign_outbreak_actions', {
        target_pest: analysis.pest_name,
        target_lat: post.latitude,
        target_long: post.longitude,
        radius_km: 15,
        action_title: taskTitle,
        action_description: taskDesc
      })

      if (rpcError) throw rpcError
    }

    return new Response(JSON.stringify({ success: true, count }), {
      headers: { "Content-Type": "application/json" },
    })

  } catch (err) {
    console.error("Function Error:", err.message)
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})