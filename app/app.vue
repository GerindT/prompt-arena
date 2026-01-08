<script setup lang="ts">
const user = useSupabaseUser()
</script>

<template>
  <div class="min-h-screen bg-gray-50 dark:bg-dark-950 font-sans selection:bg-primary-500 selection:text-white transition-colors duration-300 flex flex-col">
    <!-- Navbar -->
    <nav class="fixed top-0 w-full z-50 transition-all duration-300 glass border-b border-gray-200 dark:border-white/5">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          
          <!-- Logo -->
          <div class="flex items-center gap-4">
            <NuxtLink to="/" class="group flex items-center gap-2">
              <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-primary-500 to-purple-600 flex items-center justify-center text-white font-bold shadow-lg shadow-primary-500/20 group-hover:shadow-primary-500/40 transition-shadow duration-300">
                A
              </div>
              <span class="text-xl font-display font-bold bg-clip-text text-transparent bg-gradient-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-400">
                Prompt Arena
              </span>
            </NuxtLink>

            <!-- Desktop Nav -->
            <div class="hidden md:flex items-center gap-1 ml-6">
              <NuxtLink 
                to="/" 
                class="px-4 py-1.5 rounded-full text-sm font-medium transition-all duration-300 hover:bg-gray-100 dark:hover:bg-white/5 text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                active-class="bg-gray-100 dark:bg-white/10 text-gray-900 dark:text-white shadow-sm"
              >
                Vote
              </NuxtLink>
              <NuxtLink 
                to="/leaderboard" 
                class="px-4 py-1.5 rounded-full text-sm font-medium transition-all duration-300 hover:bg-gray-100 dark:hover:bg-white/5 text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                active-class="bg-gray-100 dark:bg-white/10 text-gray-900 dark:text-white shadow-sm"
              >
                Leaderboard
              </NuxtLink>
            </div>
          </div>

          <!-- Right Side Actions -->
          <div class="flex items-center gap-3">
            <ThemeToggle />
            
            <template v-if="user">
              <NuxtLink to="/profile" class="hidden sm:inline-flex items-center justify-center h-10 w-10 rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 font-bold border border-primary-200 dark:border-primary-500/30 hover:shadow-lg shadow-primary-500/20 transition-all">
                {{ user.email?.charAt(0).toUpperCase() }}
              </NuxtLink>
            </template>
            <template v-else>
              <NuxtLink to="/login" class="hidden sm:inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-white transition-all duration-200 bg-gray-900 dark:bg-white dark:text-gray-900 rounded-full hover:bg-gray-800 dark:hover:bg-gray-100 shadow-lg shadow-gray-900/20 dark:shadow-white/10">
                Sign In
              </NuxtLink>
            </template>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-grow pt-24 pb-12 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto w-full relative">
       <!-- Decoration Gradients -->
       <div class="fixed top-0 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl pointer-events-none -z-10 mix-blend-multiply dark:mix-blend-screen animate-pulse-slow"></div>
       <div class="fixed bottom-0 right-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl pointer-events-none -z-10 mix-blend-multiply dark:mix-blend-screen animate-pulse-slow" style="animation-delay: 1.5s"></div>
       
       <NuxtPage />
    </main>

    <!-- Footer -->
    <footer class="border-t border-gray-200 dark:border-white/5 bg-white/50 dark:bg-black/20 backdrop-blur-sm py-8">
      <div class="max-w-7xl mx-auto px-4 text-center text-sm text-gray-500 dark:text-gray-400">
        <p>© {{ new Date().getFullYear() }} Prompt Arena. Crafted with Nuxt & Supabase.</p>
      </div>
    </footer>
  </div>
</template>
