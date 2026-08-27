// Estado compartilhado por chave, seguro para SSR.
// Qualquer componente que chamar useCounter() acessa o MESMO valor.
export const useCounter = () => useState('count', () => 0)
