 <template>
 <div>
 <h1>Posts</h1>
 <div v-if="pending">Carregando...</div>
 <ul v-else>
 <li v-for="post in data" :key="post.id">
 <strong>{{ post.title }}</strong>
 </li>
 </ul>
 </div>
 </template>

 <script setup>
 const { data, pending, error } = await useFetch('https://jsonplaceholder.typicode.com/posts')
 </script>