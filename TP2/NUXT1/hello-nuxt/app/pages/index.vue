<template>
<div>
<h1>Bem-vindo ao Nuxt 3</h1>
<p>Esta é a página inicial</p>
<NuxtLink to="/sobre">Ir para Sobre</NuxtLink>
<div>
<NuxtLink to="/profiles">Ir para Perfis</NuxtLink>
</div>
<NuxtLink to="/posts">Ir para Posts</NuxtLink>
</div>
<div>
<h1>Home</h1>
<HelloWorld name="Daniel" />
 <HelloWorld name="Porto" />
 </div>
 <div>
<h2>Contador: {{ count }}</h2>
 <button @click="count++">+1</button>
 <NuxtLink to="/contato">Ir para contato</NuxtLink>
 </div>
 </template>

 <script setup>
 const count = useCounter()
 </script>