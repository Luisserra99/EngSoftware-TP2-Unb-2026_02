<template>
<div class="card">
<img v-if="avatar" :src="avatar" alt="avatar" class="avatar" />
<h3>{{ name }}</h3>
<p v-if="age">Idade: {{ age }}</p>
<slot name="extra"></slot>
</div>
</template>
<script setup>
const props = defineProps({
name: { type: String, required: true },
age: { type: Number, default: null },
avatar: { type: String, default: '' }
})
</script>
<style scoped>
.card { border: 1px solid #ddd; padding: 12px; border-radius: 8px; width: 220px; text-align:center;
}
.avatar { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; margin-bottom:8px; }
</style>