<template>
    <div>
        <h1>Página Sobre</h1>
            <p>Esta página foi criada automaticamente pela pasta /pages</p>
    <p>O contador global está em: {{ count }}</p>
    <button @click="count++">+1 daqui</button>
    <NuxtLink to="/">Voltar para Home</NuxtLink>
    </div>
</template>

<script setup>
const count = useCounter()
</script>