<script setup lang="ts">
const colorMode = useColorMode()

const toggleTheme = () => {
  colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark'
}
</script>

<template>
  <button 
    @click="toggleTheme" 
    class="relative p-2 rounded-full overflow-hidden transition-all duration-300 hover:bg-gray-100 dark:hover:bg-gray-800"
    title="Toggle Theme"
  >
    <div class="relative w-6 h-6">
      <Icon 
        name="heroicons:sun-20-solid" 
        class="absolute inset-0 w-full h-full text-yellow-500 transition-all duration-500 transform"
        :class="colorMode.value === 'dark' ? 'rotate-90 opacity-0 scale-50' : 'rotate-0 opacity-100 scale-100'"
      />
      <Icon 
        name="heroicons:moon-20-solid" 
        class="absolute inset-0 w-full h-full text-indigo-400 transition-all duration-500 transform"
        :class="colorMode.value === 'dark' ? 'rotate-0 opacity-100 scale-100' : '-rotate-90 opacity-0 scale-50'"
      />
    </div>
  </button>
</template>
