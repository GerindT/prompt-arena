<script setup lang="ts">
const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const route = useRoute()

const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')
const successMsg = ref('')
const isSignUp = ref(false)

// Check for verification redirect
onMounted(() => {
  // Supabase automatically handles the hash token for session
  // We can just watch the user object or check query params purely for UI feedback
  if (user.value) {
    router.push('/profile')
  }
})

// Redirect if already logged in (watcher)
watch(user, (newUser) => {
  if (newUser) {
    // Optional: Add a small delay or animation here
    router.push('/profile')
  }
})

const handleAuth = async () => {
  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''
  
  try {
    if (isSignUp.value) {
      const { error } = await client.auth.signUp({
        email: email.value,
        password: password.value,
        options: {
          emailRedirectTo: window.location.origin + '/login'
        }
      })
      if (error) throw error
      successMsg.value = 'Verification link sent! Please check your email.'
    } else {
      const { error } = await client.auth.signInWithPassword({
        email: email.value,
        password: password.value
      })
      if (error) throw error
      // watchEffect/watch will handle redirect
    }
  } catch (error: any) {
    if (error.message.includes('Invalid login credentials')) {
      errorMsg.value = 'Invalid email or password.'
    } else {
      errorMsg.value = error.message
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex min-h-[calc(100vh-8rem)] items-center justify-center py-12 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
    <!-- BG Gradients -->
    <div class="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-lg h-full bg-gradient-to-tr from-purple-500/20 via-transparent to-blue-500/20 blur-3xl -z-10 pointer-events-none"></div>

    <div class="w-full max-w-md space-y-8 glass p-10 rounded-3xl border border-white/20 dark:border-white/10 shadow-2xl relative z-10 transition-all duration-500 hover:shadow-primary-500/10 hover:border-primary-500/30">
      
      <div class="text-center">
        <div class="mx-auto h-16 w-16 mb-6 rounded-2xl bg-gradient-to-br from-primary-500 to-purple-600 flex items-center justify-center shadow-lg shadow-primary-500/30 transform rotate-3">
           <Icon name="ph:lightning-duotone" size="32" class="text-white" />
        </div>
        <h2 class="text-3xl font-display font-bold tracking-tight text-gray-900 dark:text-white">
          {{ isSignUp ? 'Create an account' : 'Welcome back' }}
        </h2>
        <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
          {{ isSignUp ? 'Join the Prompt Arena community' : 'Sign in to access your profile' }}
        </p>
      </div>

      <form class="mt-8 space-y-6" @submit.prevent="handleAuth">
        <div class="space-y-4">
          <div>
            <label for="email-address" class="sr-only">Email address</label>
            <div class="relative group">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400 group-focus-within:text-primary-500 transition-colors">
                <Icon name="ph:envelope-simple-duotone" size="20" />
              </div>
              <input 
                id="email-address" 
                v-model="email"
                name="email" 
                type="email" 
                autocomplete="email" 
                required 
                class="appearance-none relative block w-full px-3 py-3 pl-10 border border-gray-300 dark:border-gray-700 placeholder-gray-500 text-gray-900 dark:text-white rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent focus:z-10 sm:text-sm bg-white/50 dark:bg-black/20 transition-all" 
                placeholder="Email address" 
              />
            </div>
          </div>
          <div>
            <label for="password" class="sr-only">Password</label>
            <div class="relative group">
               <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400 group-focus-within:text-primary-500 transition-colors">
                <Icon name="ph:lock-key-duotone" size="20" />
              </div>
              <input 
                id="password" 
                v-model="password"
                name="password" 
                type="password" 
                autocomplete="current-password" 
                required 
                class="appearance-none relative block w-full px-3 py-3 pl-10 border border-gray-300 dark:border-gray-700 placeholder-gray-500 text-gray-900 dark:text-white rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent focus:z-10 sm:text-sm bg-white/50 dark:bg-black/20 transition-all" 
                placeholder="Password" 
              />
            </div>
          </div>
        </div>

        <div v-if="errorMsg" class="rounded-xl bg-red-50 dark:bg-red-900/20 p-4 border border-red-200 dark:border-red-500/30 animate-fade-in">
          <div class="flex">
            <div class="flex-shrink-0">
              <Icon name="ph:warning-circle-duotone" class="h-5 w-5 text-red-400" aria-hidden="true" />
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800 dark:text-red-200">Authentication Error</h3>
              <div class="mt-2 text-sm text-red-700 dark:text-red-300">
                <p>{{ errorMsg }}</p>
              </div>
            </div>
          </div>
        </div>

        <div v-if="successMsg" class="rounded-xl bg-green-50 dark:bg-green-900/20 p-4 border border-green-200 dark:border-green-500/30 animate-fade-in">
          <div class="flex">
            <div class="flex-shrink-0">
               <Icon name="ph:check-circle-duotone" class="h-5 w-5 text-green-400" aria-hidden="true" />
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-green-800 dark:text-green-200">Success!</h3>
              <div class="mt-2 text-sm text-green-700 dark:text-green-300">
                <p>{{ successMsg }}</p>
              </div>
            </div>
          </div>
        </div>

        <div>
          <button 
            type="submit" 
            :disabled="loading"
            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-xl text-white bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-lg shadow-primary-500/30 transform transition-all active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed overflow-hidden"
          >
             <div class="absolute inset-0 w-full h-full bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700 skew-x-12"></div>
            <span v-if="loading" class="flex items-center gap-2">
              <Icon name="eos-icons:loading" class="animate-spin" /> Processing...
            </span>
            <span v-else>{{ isSignUp ? 'Sign Up' : 'Sign In' }}</span>
          </button>
        </div>
        
        <div class="text-center mt-4">
           <button 
            type="button"
            @click="isSignUp = !isSignUp; errorMsg = ''; successMsg = ''"
            class="text-sm font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300 transition-colors"
          >
            {{ isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up" }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
