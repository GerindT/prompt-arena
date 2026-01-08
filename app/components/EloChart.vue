<script setup lang="ts">
import type { Generation } from '~/types'

const props = defineProps<{
  generations: Generation[]
}>()

const chartData = computed(() => {
    if (!props.generations.length) return []
    
    // Create buckets for Elo distribution
    // e.g., 1000-1100, 1100-1200, etc.
    const buckets: Record<string, number> = {}
    const min = 1000
    const max = 1500 // Cap for visual clarity or dynamic?
    const step = 50
    
    // Initialize buckets
    for (let i = min; i < max; i += step) {
        buckets[i] = 0
    }
    
    props.generations.forEach(g => {
        const elo = g.elo_rating
        // Find bucket
        const bucketStart = Math.floor(elo / step) * step
        if (bucketStart >= min && bucketStart < max) {
            buckets[bucketStart] = (buckets[bucketStart] || 0) + 1
        }
    })
    
    return Object.entries(buckets).map(([key, count]) => ({
        label: key,
        value: count,
        height: 0 // Will be calculated
    }))
})

const maxCount = computed(() => Math.max(...chartData.value.map(d => d.value), 1))

const bars = computed(() => {
    return chartData.value.map((d, i) => {
        const heightPercent = (d.value / maxCount.value) * 100
        return {
            ...d,
            height: isNaN(heightPercent) ? 0 : heightPercent,
            x: i * (100 / chartData.value.length)
        }
    })
})
</script>

<template>
  <div class="w-full h-32 flex items-end gap-1 pt-4">
    <div 
        v-for="(bar, i) in bars" 
        :key="i"
        class="flex-1 bg-gray-200 dark:bg-white/5 rounded-t-sm relative group transition-all hover:bg-primary-500/50"
        :style="{ height: `${Math.max(bar.height, 4)}%` }"
    >
        <!-- Tooltip -->
        <div class="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 bg-black/80 text-white text-[10px] rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none z-10">
            {{ bar.label }}-{{ parseInt(bar.label) + 50 }}: {{ bar.value }}
        </div>
    </div>
  </div>
  <div class="flex justify-between text-[10px] text-gray-400 font-mono mt-1 px-1">
     <span>1000</span>
     <span>1250</span>
     <span>1500+</span>
  </div>
</template>
