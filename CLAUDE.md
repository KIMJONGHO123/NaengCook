# NaengCook 개발 규칙

4인 캡스톤 프로젝트: AI 기반 냉장고 식재료 관리 및 레시피 추천 모바일 앱.
현재는 개발 환경만 구축한 단계다. 요청 없이 인증, 식재료 CRUD, AI, 추천, 알림,
엔티티/테이블, 배포 또는 복잡한 계층을 추가하지 않는다.

## 구조와 기술
- `apps/mobile`: React Native 0.86, Expo SDK 57, TypeScript, Expo Router, npm.
- `apps/server`: Java 21, Spring Boot 3.5.16, Gradle Wrapper 8.14.3.
- 현재 개발 DB: 직접 설치한 로컬 MySQL, 기본 포트 3306 (검증 PC: 8.0.46).
- `compose.yaml`: 나중에 사용할 MySQL 8.4 LTS 구성. 현재 개발에 Docker를 요구하지 않는다.
- `docs`: 팀 개발 문서 및 검증 기록.

## 구현 규칙
- 모바일 라우트는 `apps/mobile/src/app`, 라우트 외 코드는 `src`의 관련 폴더에 둔다.
- Expo 공식 SDK 57 문서와 `expo install`을 사용해 패키지 호환성을 유지한다.
- 서버 패키지는 `com.capstone.fridgerecipe`. 필요한 만큼만 클래스와 계층을 추가한다.
- Gradle Wrapper와 `package-lock.json`을 버전 관리한다. 팀원은 `npm ci`를 사용한다.
- 기존 코드와 사용자의 변경을 먼저 확인하고, 임의로 삭제하거나 덮어쓰지 않는다.
- 공통 설정 변경은 README에 반영한다. 기능 브랜치와 PR로 협업한다.

## 환경변수와 보안
- 루트 `.env`는 로컬 DB/서버 전용, 모바일 `.env`는 공개 API 주소 전용이다.
- `.env`, 비밀키, DB 비밀번호를 커밋하거나 로그에 출력하지 않는다.
- `EXPO_PUBLIC_*`는 앱에 포함되므로 비밀을 넣지 않는다.
- 운영은 `prod` 프로필과 외부 환경변수를 사용한다. 로컬 DB를 운영에 사용하지 않는다.
- JPA `ddl-auto=none`을 유지한다. 실제 스키마는 별도 요청 시 설계한다.

## 검증 명령 (PowerShell)
Windows 모바일은 루트 `mobile.cmd`를 사용해 `.nvmrc` 버전을 적용한다.
전용 런타임이 없으면 `powershell -ExecutionPolicy Bypass -File scripts/setup-node.ps1`로 준비한다.
루트: `.\mobile.cmd run typecheck`, `.\mobile.cmd run lint`.
로컬 DB 최초 설정: `powershell -ExecutionPolicy Bypass -File scripts/setup-local-mysql.ps1`.
관리자 비밀번호는 로컬 PowerShell 보안 입력 프롬프트에만 입력한다. Docker는 후속 단계로 미룬다.
모바일: `cd apps/mobile`, `npm ci`, `npm run typecheck`, `npm run lint`,
`npx expo install --check`, `npx expo-doctor`, `npm start`.
서버: `cd apps/server`, `.\gradlew.bat clean build`, `.\gradlew.bat bootRun`.
서버 상태 확인: `Invoke-RestMethod http://localhost:8080/api/status`.
테스트는 H2 인메모리 DB를 사용하며 실제 MySQL 검증과 구분해 보고한다.
실행하지 않은 검증을 성공으로 보고하지 않는다.
