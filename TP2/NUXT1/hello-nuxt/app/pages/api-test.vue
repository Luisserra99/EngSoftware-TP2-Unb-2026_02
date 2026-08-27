<template>
 <div>
 <h1>Teste API</h1>
 <p>{{ data }}</p>
 </div>
 </template>
<script setup>
 const { data } = await useFetch('/api/hello')
</script>