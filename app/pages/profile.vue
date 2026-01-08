<script setup lang="ts">
const user = useSupabaseUser()
const client = useSupabaseClient()
const router = useRouter()

/* middleware: auth */
definePageMeta({
  middleware: [
    function (to, from) {
      const user = useSupabaseUser()
      if (!user.value) {
        return navigateTo('/login')
      }
    }
  ]
})

const signOut = async () => {
  await client.auth.signOut()
  router.push('/login')
}
</script>

<template>
  <div v-if="user" class="max-w-4xl mx-auto py-8">
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

    <!-- Stats Grid (Placeholder for now) -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <div class="glass p-6 rounded-2xl border border-gray-200 dark:border-white/10">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Total Votes Cast</div>
        <div class="text-3xl font-bold font-display">0</div>
      </div>
      <div class="glass p-6 rounded-2xl border border-gray-200 dark:border-white/10">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Generations Uploaded</div>
        <div class="text-3xl font-bold font-display">0</div>
      </div>
      <div class="glass p-6 rounded-2xl border border-gray-200 dark:border-white/10">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Highest Elo</div>
        <div class="text-3xl font-bold font-display">-</div>
      </div>
    </div>

    <!-- Empty State for Uploads -->
    <div class="text-center py-12 border-2 border-dashed border-gray-200 dark:border-gray-800 rounded-3xl">
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
