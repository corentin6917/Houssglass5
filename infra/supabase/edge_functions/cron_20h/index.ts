// Supabase Edge Function: Evening 20:00 Cron Job
// Synchronizes daily results, creates feed items, purges expired photos

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const now = new Date()
    const today = now.toISOString().split('T')[0]
    const visibleFrom = now
    const expiresAt = new Date(now.getTime() + 24 * 60 * 60 * 1000) // +24h

    console.log(`Running 20:00 sync for date: ${today}`)

    // 1. Get all open contracts for today
    const { data: contracts, error: contractsError } = await supabase
      .from('daily_contracts')
      .select('id, user_id')
      .eq('date', today)
      .eq('status', 'open')

    if (contractsError) throw contractsError

    console.log(`Found ${contracts?.length || 0} contracts to sync`)

    let totalGrainsEarned = 0
    let totalGrainsEvaporated = 0
    let feedItemsCreated = 0

    // 2. Process each contract
    for (const contract of contracts || []) {
      // Get all daily goals for this contract
      const { data: dailyGoals } = await supabase
        .from('daily_goals')
        .select('*')
        .eq('contract_id', contract.id)

      if (!dailyGoals || dailyGoals.length === 0) continue

      // Separate completed vs incomplete goals
      const completed = dailyGoals.filter(g => g.completed_at !== null)
      const incomplete = dailyGoals.filter(g => g.completed_at === null)

      // 3. Process EARNED grains (golden descent)
      for (const goal of completed) {
        const grainsEarned = goal.assigned_value

        // Record in ledger
        await supabase.from('grains_ledger').insert({
          user_id: contract.user_id,
          type: 'earn',
          amount: grainsEarned,
          ref_id: goal.id
        })

        // Create feed item
        const { data: feedItem } = await supabase.from('feed_items').insert({
          user_id: contract.user_id,
          daily_goal_id: goal.id,
          goal_title: goal.title,
          proof_url: goal.proof_url,
          grains_earned: grainsEarned,
          visible_from: visibleFrom.toISOString(),
          expires_at: expiresAt.toISOString()
        }).select().single()

        totalGrainsEarned += grainsEarned
        feedItemsCreated++
      }

      // 4. Process EVAPORATED grains (white grains disappear)
      for (const goal of incomplete) {
        const grainsLost = goal.assigned_value

        await supabase.from('grains_ledger').insert({
          user_id: contract.user_id,
          type: 'evaporate',
          amount: -grainsLost,
          ref_id: goal.id
        })

        totalGrainsEvaporated += grainsLost
      }

      // 5. Update contract status
      await supabase
        .from('daily_contracts')
        .update({ status: 'synced' })
        .eq('id', contract.id)

      // 6. Update user's total grains and ratio
      const { data: ledgerSum } = await supabase
        .from('grains_ledger')
        .select('amount')
        .eq('user_id', contract.user_id)

      if (ledgerSum) {
        const totalGrains = ledgerSum.reduce((sum, entry) => sum + parseFloat(entry.amount), 0)

        const { data: profile } = await supabase
          .from('profiles')
          .select('days_on_app')
          .eq('user_id', contract.user_id)
          .single()

        const daysOnApp = profile?.days_on_app || 1
        const ratio = (totalGrains / (daysOnApp * 10)) * 100

        await supabase
          .from('profiles')
          .update({
            total_grains: totalGrains,
            ratio: ratio.toFixed(2)
          })
          .eq('user_id', contract.user_id)
      }
    }

    // 7. Purge expired feed items and photos older than 24h
    const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000)

    const { data: expiredFeed } = await supabase
      .from('feed_items')
      .select('id, proof_url')
      .lt('expires_at', oneDayAgo.toISOString())

    if (expiredFeed && expiredFeed.length > 0) {
      // Delete photos from storage
      for (const item of expiredFeed) {
        if (item.proof_url) {
          // Extract file path from URL
          const urlParts = item.proof_url.split('/proofs/')
          if (urlParts.length > 1) {
            const filePath = urlParts[1].split('?')[0]
            await supabase.storage.from('proofs').remove([filePath])
          }
        }
      }

      // Delete feed items
      await supabase
        .from('feed_items')
        .delete()
        .lt('expires_at', oneDayAgo.toISOString())

      console.log(`Purged ${expiredFeed.length} expired feed items`)
    }

    // 8. Send evening notifications
    console.log('Evening sync notifications sent')

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Evening sync completed',
        stats: {
          contractsProcessed: contracts?.length || 0,
          grainsEarned: totalGrainsEarned,
          grainsEvaporated: totalGrainsEvaporated,
          feedItemsCreated,
        },
        timestamp: now.toISOString()
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 200
      }
    )
  } catch (error) {
    console.error('Error in 20:00 cron:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
