<script setup lang="ts">
import type { Generation } from '~/types'

const client = useSupabaseClient()
const generations = ref<Generation[]>([])
const loading = ref(true)

// Fetch top rated generations
const fetchLeaderboard = async () => {
  loading.value = true
  const { data, error } = await client
    .from('generations')
    .select('*')
    .order('elo_rating', { ascending: false })
    .limit(50)
    
  if (data) {
    generations.value = data
  }
  loading.value = false
}

onMounted(() => {
  fetchLeaderboard()
})
</script>

<template>
  <div class="py-8">
    <div class="mb-12 text-center">
      <h1 class="text-3xl md:text-5xl font-bold mb-4 font-display">Leaderboard</h1>
      <p class="text-gray-400 max-w-lg mx-auto mb-8">The highest rated generations of all time. Compete to reach the top of the arena.</p>
      
      <!-- Elo Distribution Chart -->
      <div v-if="!loading && generations.length > 0" class="max-w-md mx-auto p-6 glass rounded-2xl border border-gray-200 dark:border-white/10">
         <h3 class="text-xs uppercase tracking-wider text-gray-400 font-bold mb-2 text-left">Rating Distribution</h3>
         <EloChart :generations="generations" />
      </div>
    </div>

    <div v-if="loading" class="space-y-4">
      <div v-for="i in 5" :key="i" class="h-24 bg-gray-100 dark:bg-gray-900 rounded-xl animate-pulse"></div>
    </div>

    <div v-else class="grid gap-4 max-w-4xl mx-auto">
      <div 
        v-for="(gen, index) in generations" 
        :key="gen.id"
        class="bg-gray-900 rounded-xl p-4 flex items-center gap-6 border border-gray-800 hover:border-gray-700 transition-colors"
      >
        <div class="flex-shrink-0 w-12 text-center">
          <span 
            class="text-2xl font-black"
            :class="{
              'text-yellow-400': index === 0,
              'text-gray-300': index === 1,
              'text-orange-400': index === 2,
              'text-gray-600': index > 2
            }"
          >
            #{{ index + 1 }}
          </span>
        </div>

        <div class="flex-shrink-0 w-20 h-20 rounded-lg overflow-hidden bg-gray-800">
          <img :src="gen.content" class="w-full h-full object-cover" loading="lazy" />
        </div>

        <div class="flex-grow">
          <div class="font-mono text-xs text-gray-500 mb-1">ID: {{ gen.id.slice(0, 8) }}</div>
          <div class="flex items-center gap-2">
            <span class="text-xl font-bold text-white">{{ gen.elo_rating }}</span>
            <span class="text-xs text-gray-400 uppercase tracking-wider">Elo</span>
          </div>
        </div>
        
        <div class="hidden sm:block text-right text-sm text-gray-500">
          {{ new Date(gen.created_at).toLocaleDateString() }}
        </div>
      </div>
    </div>
  </div>
</template>
