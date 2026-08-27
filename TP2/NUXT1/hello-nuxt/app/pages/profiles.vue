<template>
    <div class="profile-page">
        <h1>Perfil de Usuário</h1>
        <ProfileCard name="Daniela" age="30" avatar="https://i.pravatar.cc/150?u=Daniela">
        <template #extra>
            <p>Este é um usuário fictício.</p>
        </template>
        </ProfileCard>
        <ProfileCard name="Maria" age="25" avatar="https://i.pravatar.cc/150?u=Maria">
        <template #extra>
            <p>Outro usuário fictício.</p>
        </template>
        </ProfileCard>
    </div>
    </template>
    <style scoped>
    .profile-page {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 20px;
    }
    </style>