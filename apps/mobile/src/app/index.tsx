import { StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { API_URL } from '@/config/api';

export default function HomeScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>NaengCook</Text>
        <Text style={styles.description}>냉장고 식재료 관리 및 레시피 추천 앱</Text>
        <Text style={styles.description}>초기 개발 환경이 준비되었습니다.</Text>
        <Text selectable style={styles.address}>API: {API_URL}</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f5f9f7' },
  content: { flex: 1, justifyContent: 'center', padding: 24, gap: 16 },
  title: { fontSize: 32, fontWeight: '700', color: '#183f31' },
  description: { fontSize: 16, color: '#33443d' },
  address: { fontSize: 14, color: '#52665c' },
});
