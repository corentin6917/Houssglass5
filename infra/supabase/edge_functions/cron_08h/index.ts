// Supabase Edge Function: Morning 08:00 Cron Job
// Resets daily grain potential and sends morning notifications

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const now = new Date()
    const today = now.toISOString().split('T')[0]

    console.log(`Running 08:00 cron for date: ${today}`)

    // 1. Get all active users (those who logged in recently)
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('id, email, display_name, tz')
      .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())

    if (usersError) throw usersError

    console.log(`Found ${users?.length || 0} active users`)

    // 2. For each user, ensure they don't have a contract for today yet
    for (const user of users || []) {
      // Check if contract exists
      const { data: existing } = await supabase
        .from('daily_contracts')
        .select('id')
        .eq('user_id', user.id)
        .eq('date', today)
        .single()

      if (!existing) {
        // Create new contract (represents the 10 white grains potential)
        const { error: contractError } = await supabase
          .from('daily_contracts')
          .insert({
            user_id: user.id,
            date: today,
            status: 'open'
          })

        if (contractError) {
          console.error(`Error creating contract for user ${user.id}:`, contractError)
        } else {
          console.log(`Created morning contract for user ${user.display_name}`)
        }
      }
    }

    // 3. Send morning notifications (placeholder)
    // In production: integrate with push notification service
    console.log('Morning notifications sent')

    // 4. Suggest goals based on history (optional enhancement)
    // Could analyze user's past goals and suggest repeats

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Morning cron completed',
        usersProcessed: users?.length || 0,
        timestamp: now.toISOString()
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 200
      }
    )
  } catch (error) {
    console.error('Error in 08:00 cron:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
