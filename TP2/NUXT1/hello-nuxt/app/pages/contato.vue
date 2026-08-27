<template>
 <div>
 <h1>Contato</h1>
 <p>O contador global está em: {{ count }}</p>
 <NuxtLink to="/">Voltar</NuxtLink>
 </div>
 <div>
 <h2>Perfil</h2>
    <profileCard name="João" :age="28" avatar="https://i.pravatar.cc/150?u=Joao">
    <template #extra>
    <p>Estudante de Ciência da Computação</p>
    </template>
</profileCard>
 </div>
  </template>

 <script setup>
 const count = useCounter()
 </script>