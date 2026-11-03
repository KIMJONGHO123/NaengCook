Expo/React Native 모바일 앱이다. 모바일 우선 패턴, 성능, 크로스 플랫폼 호환성을 우선한다.

## Expo는 계속 바뀐다 — 학습 데이터를 신뢰하지 않는다

Expo는 SDK 릴리스마다 호환성을 깨는 변경을 포함한다. 기억하고 있는 API는 이름이 바뀌었거나 이동·삭제됐을 가능성이 높다. Expo, EAS, React Native API를 다루는 코드를 작성하기 전에:

1. `package.json`에서 `expo` 패키지의 메이저 버전을 확인한다.
2. 해당 버전의 문서를 가져온다: `https://docs.expo.dev/versions/v<major>.0.0/`
3. 그 외 내용은 https://docs.expo.dev/llms.txt 를 가져온다 — 모든 Expo 문서의 색인이며 LLM이 흔히 틀리는 부분에 대한 정정이 포함돼 있다. 거기 링크를 따라 필요한 페이지로 이동하고, 절대 기억에 의존해 답하지 않는다.

## 명령어

프로젝트가 bun을 사용하면(`bun.lock` 존재) `npx` 대신 `bunx`를 사용한다.

```bash
npx expo install <package>  # npm/yarn/pnpm/bun add 대신 항상 사용 — SDK 호환 버전을 해결한다
npx expo start              # 개발 서버 시작
npx expo lint               # 린트
npx tsc --noEmit            # 타입 체크
npx expo-doctor             # 의존성·설정 문제 진단
npx expo install --fix      # 호환되지 않는 패키지 버전 수정
```

어떤 작업이든 완료를 선언하기 전에 린트와 타입 체크를 실행한다.

## 내비게이션 & 라우팅

- 모든 내비게이션은 **Expo Router**를 사용한다. 라우트는 `src/app/`에 둔다 — 그 안의 모든 파일이 하나의 화면이며 `_layout.tsx` 파일이 내비게이터를 정의한다. 라우트가 아닌 코드(컴포넌트, 훅, 유틸)는 `src/app/` 밖에 둔다.
- `Link`, `router`, `useLocalSearchParams`는 `expo-router`에서 import 한다.
- 문서: https://docs.expo.dev/router/introduction.md

## EAS로 빌드

EAS를 사용해 클라우드에서 앱을 빌드·서명·제출하고(`eas build`, `eas submit`), 무선(OTA) 업데이트를 배포한다(`eas update`) — 로컬 Xcode나 Android Studio가 필요 없다. EAS CLI는 Bun 프로젝트에서 `bunx eas-cli <command>`, 그 외에는 `npx eas-cli@latest <command>`로 실행한다. 문서 예시의 맨 `eas`는 이 형태로 바꿔 쓴다.
문서: https://docs.expo.dev/eas/index.md

## 규칙

- `ios/`와 `android/` 디렉터리가 없으면 이는 생성되는 것이다(Continuous Native Generation). 직접 만들거나 수정하지 않는다 — 네이티브 동작은 `app.json`과 config 플러그인으로 설정한다.
- Expo Go에는 번들된 네이티브 모듈만 포함된다. 네이티브 코드가 있는 라이브러리를 추가한 뒤에는 development build가 필요하다: 로컬에서 `npx expo run:ios|android`, 또는 `eas build --profile development`.
- 서드파티 라이브러리보다 권장 Expo 모듈을 우선하고, 의존성을 추가하기 전에 사용 가능한 skill을 확인한다. 문서: https://docs.expo.dev/versions/latest/index.md
