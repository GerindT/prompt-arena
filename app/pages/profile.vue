<script setup lang="ts">
import type { Generation } from '~/types'

const user = useSupabaseUser()
const client = useSupabaseClient()
const router = useRouter()

/* middleware: auth */
definePageMeta({
  middleware: 'auth'
})

const myGenerations = ref<Generation[]>([])
const loading = ref(true)

const fetchProfileData = async () => {
  loading.value = true
  
  // 1. Try to get ID from reactive user
  let userId = user.value?.id
  
  // 2. Fallback: Fetch explicitly if missing
  if (!userId) {
     const { data } = await client.auth.getUser()
     userId = data.user?.id
  }

  if (!userId) {
    console.warn('Authentication check failed: No User ID found after fallback')
    loading.value = false
    return
  }

  try {
    const { data, error } = await client
      .from('generations')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      
    if (error) throw error
    myGenerations.value = data as Generation[] || []
  } catch (e: any) {
    console.error('Error fetching profile:', e.message)
  } finally {
    loading.value = false
  }
}

// Watch user but also force fetch on mount if needed
watch(user, async (newUser) => {
  if (newUser) {
     await fetchProfileData()
  }
}, { immediate: true, deep: true })

onMounted(async () => {
    // Force a fetch attempt on mount, which will trigger the fallback if needed
    await fetchProfileData()
    
    // Safety timeout
    setTimeout(() => {
        if (loading.value) {
            loading.value = false
        }
    }, 5000)
})

const highestElo = computed(() => {
  if (myGenerations.value.length === 0) return '-'
  return Math.max(...myGenerations.value.map(g => g.elo_rating))
})

const totalUploads = computed(() => myGenerations.value.length)

const signOut = async () => {
  await client.auth.signOut()
  router.push('/login')
}
</script>

<template>
  <div v-if="user" class="max-w-6xl mx-auto py-8">
    <!-- Header Card -->
    <div class="glass rounded-3xl p-8 mb-8 border border-gray-200 dark:border-white/10 relative overflow-hidden group">
      <div class="absolute top-0 right-0 p-8 opacity-10 group-hover:opacity-20 transition-opacity">
        <Icon name="ph:user-circle-duotone" size="120" />
      </div>
      
      <div class="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div>
          <div class="flex items-center gap-3 mb-2">
            <h1 class="text-3xl font-bold font-display">Your Profile</h1>
            <span class="px-2 py-0.5 rounded-full bg-primary-500/10 border border-primary-500/20 text-xs font-mono text-primary-500">BETA</span>
          </div>
          <p class="text-gray-500 dark:text-gray-400 font-mono">{{ user.email }}</p>
          <div class="mt-4 text-xs text-gray-400">
            User ID: {{ user.id }}
          </div>
        </div>
        
        <button 
          @click="signOut"
          class="px-5 py-2.5 rounded-xl border border-gray-200 dark:border-white/10 hover:bg-red-500/10 hover:border-red-500/20 hover:text-red-500 transition-all text-sm font-medium"
        >
          Sign Out
        </button>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
      <div class="glass p-6 rounded-2xl border border-gray-200 dark:border-white/10">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Generations Uploaded</div>
        <div class="text-3xl font-bold font-display">{{ totalUploads }}</div>
      </div>
      <div class="glass p-6 rounded-2xl border border-gray-200 dark:border-white/10">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Highest Elo</div>
        <div class="text-3xl font-bold font-display text-primary-500">{{ highestElo }}</div>
      </div>
    </div>

    <!-- Uploads Section -->
    <div class="mb-6 flex items-center justify-between">
      <h2 class="text-2xl font-bold font-display">Your Uploads</h2>
      <NuxtLink 
        to="/upload"
        class="inline-flex items-center px-4 py-2 rounded-full bg-primary-600 hover:bg-primary-500 text-white font-medium text-sm transition-colors shadow-lg shadow-primary-500/20"
      >
        <Icon name="ph:plus-bold" class="mr-2" />
        New Upload
      </NuxtLink>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="grid grid-cols-2 md:grid-cols-4 gap-6 animate-pulse">
        <div v-for="i in 4" :key="i" class="aspect-square bg-gray-200 dark:bg-white/5 rounded-2xl"></div>
    </div>

    <!-- Grid -->
    <div v-else-if="myGenerations.length > 0" class="grid grid-cols-2 md:grid-cols-4 gap-6">
      <div v-for="gen in myGenerations" :key="gen.id" class="group relative aspect-square rounded-2xl overflow-hidden bg-gray-100 dark:bg-white/5 border border-gray-200 dark:border-white/10">
        <img :src="gen.content" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity p-4 flex flex-col justify-end">
          <div class="text-white font-bold text-lg">{{ gen.elo_rating }}</div>
          <div class="text-gray-300 text-xs">Elo Rating</div>
        </div>
      </div>
    </div>
    
    <!-- Empty State -->
    <div v-else class="text-center py-12 border-2 border-dashed border-gray-200 dark:border-gray-800 rounded-3xl">
      <div class="inline-flex p-4 rounded-full bg-gray-100 dark:bg-gray-900 mb-4 text-gray-400">
        <Icon name="ph:images-duotone" size="32" />
      </div>
      <h3 class="text-lg font-bold mb-2">No Generations Yet</h3>
      <p class="text-gray-500 dark:text-gray-400 max-w-sm mx-auto mb-6">
        Upload your AI generations to start competing in the arena.
      </p>
      <NuxtLink 
        to="/upload"
        class="inline-flex items-center px-6 py-2.5 rounded-full bg-primary-600 hover:bg-primary-500 text-white font-medium transition-colors shadow-lg shadow-primary-500/20"
      >
        <Icon name="ph:upload-simple-bold" class="mr-2" />
        Upload Generation
      </NuxtLink>
    </div>
  </div>
</template>
