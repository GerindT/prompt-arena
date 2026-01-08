<script setup lang="ts">
const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

definePageMeta({
  middleware: 'auth'
})

const file = ref<File | null>(null)
const previewUrl = ref<string | null>(null)
const uploading = ref(false)
const dragActive = ref(false)
const errorMsg = ref('')

const handleFile = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    processFile(target.files[0])
  }
}

const handleDrop = (event: DragEvent) => {
  event.preventDefault()
  dragActive.value = false
  if (event.dataTransfer?.files && event.dataTransfer.files.length > 0) {
    processFile(event.dataTransfer.files[0])
  }
}

const processFile = (selectedFile: File) => {
  errorMsg.value = ''
  if (!selectedFile.type.startsWith('image/')) {
    errorMsg.value = 'Please upload an image file (PNG, JPG, WEBP).'
    return
  }
  if (selectedFile.size > 5 * 1024 * 1024) {
    errorMsg.value = 'File size must be less than 5MB.'
    return
  }
  
  file.value = selectedFile
  previewUrl.value = URL.createObjectURL(selectedFile)
}

const uploadImage = async () => {
  if (!file.value || !user.value) return
  
  uploading.value = true
  errorMsg.value = ''
  
  try {
    const fileExt = file.value.name.split('.').pop()
    const fileName = `${user.value.id}/${Date.now()}.${fileExt}`
    
    // 1. Upload to Storage
    const { error: uploadError } = await client.storage
      .from('generations')
      .upload(fileName, file.value)
      
    if (uploadError) throw uploadError
    
    // 2. Get Public URL
    const { data: { publicUrl } } = client.storage
      .from('generations')
      .getPublicUrl(fileName)
      
    // 3. Insert into Database
    const { error: dbError } = await client
      .from('generations')
      .insert({
        content: publicUrl,
        type: 'image',
        user_id: user.value.id,
        elo_rating: 1200 // Default rating
      })
      
    if (dbError) throw dbError
    
    // Success! Redirect to profile
    router.push('/profile')
    
  } catch (error: any) {
    errorMsg.value = error.message
  } finally {
    uploading.value = false
  }
}
</script>

<template>
  <div class="max-w-3xl mx-auto py-12">
    <div class="text-center mb-10">
      <h1 class="text-4xl font-bold font-display mb-4">Upload Generation</h1>
      <p class="text-gray-500 dark:text-gray-400">Share your AI art with the world and climb the leaderboard.</p>
    </div>
    
    <div class="glass p-8 rounded-3xl border-2 border-dashed transition-all duration-300"
      :class="[
        dragActive ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/10' : 'border-gray-200 dark:border-white/10'
      ]"
      @dragenter.prevent="dragActive = true"
      @dragleave.prevent="dragActive = false"
      @dragover.prevent="dragActive = true"
      @drop="handleDrop"
    >
      <div v-if="!file" class="text-center py-12">
         <div class="mx-auto h-20 w-20 mb-6 rounded-full bg-gray-100 dark:bg-white/5 flex items-center justify-center text-gray-400">
           <Icon name="ph:cloud-arrow-up-duotone" size="40" />
         </div>
         <h3 class="text-lg font-medium mb-2">Drag and drop your image here</h3>
         <p class="text-gray-500 text-sm mb-6">or click to browse from your computer</p>
         
         <label class="cursor-pointer inline-flex items-center justify-center px-6 py-3 border border-transparent text-sm font-medium rounded-xl text-white bg-primary-600 hover:bg-primary-700 transition-colors shadow-lg shadow-primary-500/20">
           Browse Files
           <input type="file" class="hidden" accept="image/*" @change="handleFile" />
         </label>
         <p class="mt-4 text-xs text-gray-400">Supports: PNG, JPG, WEBP (Max 5MB)</p>
      </div>

      <div v-else class="relative">
        <div class="relative rounded-2xl overflow-hidden shadow-2xl">
          <img :src="previewUrl" class="w-full h-auto max-h-[500px] object-contain bg-black/50" />
          
          <button 
            @click="file = null; previewUrl = null" 
            class="absolute top-4 right-4 p-2 rounded-full bg-black/50 hover:bg-black/70 text-white backdrop-blur-md transition-colors"
          >
            <Icon name="ph:x-bold" size="20" />
          </button>
        </div>

        <div v-if="errorMsg" class="mt-6 p-4 rounded-xl bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-300 text-center text-sm border border-red-200 dark:border-red-500/30">
          {{ errorMsg }}
        </div>

        <div class="mt-8 flex justify-center">
          <button 
            @click="uploadImage" 
            :disabled="uploading"
            class="w-full sm:w-auto min-w-[200px] py-4 px-8 rounded-xl bg-gradient-to-r from-primary-600 to-purple-600 text-white font-bold shadow-xl shadow-primary-500/30 hover:shadow-primary-500/40 transform transition-all active:scale-95 disabled:opacity-70 disabled:cursor-not-allowed"
          >
             <span v-if="uploading" class="flex items-center justify-center gap-2">
              <Icon name="eos-icons:loading" class="animate-spin" /> Uploading...
            </span>
            <span v-else>Publish to Arena</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
