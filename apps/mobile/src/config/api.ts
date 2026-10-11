// Expo statically replaces direct EXPO_PUBLIC_* references during bundling.
export const API_URL = process.env.EXPO_PUBLIC_API_URL ?? 'http://localhost:8080';
