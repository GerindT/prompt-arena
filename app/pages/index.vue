<script setup lang="ts">
import type { Generation } from '~/types'

const client = useSupabaseClient()
const loading = ref(true)
const voting = ref(false)
const pair = ref<Generation[]>([])

// Fetch a random pair of generations
const fetchPair = async () => {
  loading.value = true
  try {
    // For MVP, we just fetch 2 random items using the random() sort
    // Note: random() is slow on large tables, but okay for MVP with < 1000 rows.
    // A better approach later is calling an RPC 'get_random_pair'
    const { data, error } = await client
      .from('generations')
      .select('*')
      .limit(2)
      // This is a naive random fetch; in production use an RPC or specific logic
      // Supabase JS doesn't have a direct .random() modifier without extensions or RPC
      // So we'll fetch random IDs or implement an RPC.
      // FALLBACK for now: Let's assume we implement 'get_random_pair' RPC or just fetch all and pick 2 (bad for perf).
      // BETTER: Using a simple hack -> order by random() which works if we passed it in raw SQL, 
      // but client.from().select().order('random()') might not work directly without setup.
      // Let's rely on a helper function or for now just simplistic randomization client side if small data?
      // No, let's do it right. I will create a small RPC for this if needed, 
      // but let's try a simple approach first: 
      
      // Let's use a stored procedure for fetching random if we can, BUT
      // since I can't add more SQL right now without asking user, 
      // I will simulate it by picking a random offset if count is small.
  } catch (e) {
    console.error(e)
  }
}

// SIMPLER APPROACH FOR MVP without new SQL:
// Fetch 2 items using a Postgres function is best.
// Since I already asked user to run SQL, I should have included it.
// I will use a client-side random shuffle of a larger subset for now (fetching 50 rows) 
// or I will implement the RPC call if I can assume the user accepts a new RPC (I can't).
// WAIT, I can just use `order: { foreignTable: '', ascending: false }` tricks? No.
// Let's use the 'get_random_pair' concept but implemented in JS for now (fetch 20, pick 2).
const fetchRandomPair = async () => {
  loading.value = true
  // Fetch up to 50 items and pick 2 random ones
  const { data, error } = await client
    .from('generations')
    .select('*')
    .limit(50)
  
  if (error) {
    console.error('Error fetching pair:', error)
    return
  }
  
  if (data && data.length >= 2) {
    // Shuffle and pick 2
    const shuffled = data.sort(() => 0.5 - Math.random())
    pair.value = shuffled.slice(0, 2)
  }
  loading.value = false
}

const handleVote = async (winner: Generation) => {
  if (voting.value || pair.value.length < 2) return
  voting.value = true
  
  const loser = pair.value.find(g => g.id !== winner.id)!
  
  try {
    const { error } = await client.rpc('update_elo', {
      winner_id: winner.id,
      loser_id: loser.id
    })
    
    if (error) throw error
    
    // Success! Fetch new pair
    await fetchRandomPair()
  } catch (error) {
    console.error('Error voting:', error)
    alert('Failed to submit vote. Check console.')
  } finally {
    voting.value = false
  }
}

onMounted(() => {
  fetchRandomPair()
})
</script>

<template>
  <div class="flex flex-col items-center justify-center min-h-[80vh] py-10">
    <div class="text-center mb-12">
      <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight mb-4">
        <span class="bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-600">
          Rank the Best
        </span>
      </h1>
      <p class="text-gray-400 text-lg max-w-2xl mx-auto">
        Which generation is better? Click your favorite to vote and update their Elo rating.
      </p>
    </div>

    <div v-if="loading" class="flex gap-8 items-center justify-center">
      <div class="w-64 h-64 md:w-96 md:h-96 bg-gray-800 rounded-2xl animate-pulse"></div>
      <div class="hidden md:block text-2xl font-bold text-gray-600">VS</div>
      <div class="w-64 h-64 md:w-96 md:h-96 bg-gray-800 rounded-2xl animate-pulse"></div>
    </div>

    <div v-else-if="pair.length === 2" class="flex flex-col md:flex-row gap-8 items-center justify-center w-full max-w-6xl">
      <!-- Left Candidate -->
      <button 
        @click="handleVote(pair[0])"
        :disabled="voting"
        class="group relative flex-1 w-full max-w-md aspect-square rounded-2xl overflow-hidden border-2 border-gray-800 hover:border-purple-500 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-purple-500/30"
        :class="{ 'opacity-50 cursor-not-allowed': voting }"
      >
        <img 
          :src="pair[0].content" 
          class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
        <div class="absolute inset-x-0 bottom-0 p-4 bg-gradient-to-t from-black/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
          <span class="font-bold text-white">Select Left</span>
        </div>
      </button>

      <!-- VS Badge -->
      <div class="flex-shrink-0 z-10">
        <div class="w-16 h-16 rounded-full bg-gray-900 border-4 border-gray-800 flex items-center justify-center shadow-xl">
          <span class="font-black text-xl text-gray-500">VS</span>
        </div>
      </div>

      <!-- Right Candidate -->
      <button 
        @click="handleVote(pair[1])"
        :disabled="voting"
        class="group relative flex-1 w-full max-w-md aspect-square rounded-2xl overflow-hidden border-2 border-gray-800 hover:border-pink-500 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-pink-500/30"
        :class="{ 'opacity-50 cursor-not-allowed': voting }"
      >
        <img 
          :src="pair[1].content" 
          class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
        <div class="absolute inset-x-0 bottom-0 p-4 bg-gradient-to-t from-black/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
          <span class="font-bold text-white">Select Right</span>
        </div>
      </button>
    </div>

    <div v-else class="text-center py-20">
      <p class="text-xl text-gray-500">No generations found. Seed the database!</p>
    </div>
  </div>
</template>
