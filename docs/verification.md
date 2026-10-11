# 초기 개발 환경 검증 기록

## 최신 상태: Docker 보류, 로컬 MySQL 연결 완료

사용자 요청으로 서버 확인 경로와 컨트롤러 이름을 `/api/status`, `StatusController`로 변경했다.
관련 테스트와 문서의 명칭도 갱신했다. 변경 후 테스트 2개 통과, 서버 재시작 및
`/api/status` HTTP 200 / 제거한 이전 경로 HTTP 404를 실제로 확인했다.
아래 초기 기록의 확인 API 경로 표기도 현재 명칭으로 갱신한 것이다.

2026-10-12 사용자 요청에 따라 현재 개발 환경은 직접 설치한 **MySQL 8.0.46 / 3306**으로 변경했다.
Docker 구성은 후속 단계로 미뤘고 기존 compose.yaml은 참고용으로만 보존했다.
아래 초기 구축 기록의 Docker 미검증 내용은 당시 결과이며 현재 로컬 DB 연결 상태와 구분한다.

- 실행 중인 Windows 서비스 `MySQL80`과 MySQL 8.0.46 설치 확인.
- `.env.example`, 실제 로컬 `.env`, 서버 local 프로필의 기본 포트를 3306으로 변경.
- `scripts/setup-local-mysql.ps1` 추가: 로컬 관리자 인증으로 프로젝트 DB 및 전용 계정 초기화.
  관리자 비밀번호는 파일/명령행 인수에 저장하지 않고 mysql 자식 프로세스 환경에만 일시 전달.
- 실제 `naengcook` DB와 `naengcook@localhost` 계정 생성, 해당 DB에만 권한 부여.
  기존 업무 데이터나 기존 계정 비밀번호는 변경하지 않음.
- `gradlew.bat bootRun`: local 프로필에서 MySQL 연결 성공.
  HikariPool의 MySQL ConnectionImpl 연결, DB version 8.0.46,
  EntityManagerFactory 초기화 및 Tomcat 8080 시작 확인.
- `Invoke-WebRequest http://localhost:8080/api/status`: HTTP 200, `{"status":"UP"}` 확인.
- 전용 앱 계정으로 실제 DB 로그인, 버전/포트/DB명/문자셋 및 테이블 개수 검증.
  `utf8mb4`, `utf8mb4_0900_ai_ci`, 프로젝트 테이블 0개 확인.
- 설정 변경 후 `gradlew.bat build`: BUILD SUCCESSFUL, 테스트 2개 통과.
- README와 AGENTS.md를 로컬 MySQL 실행 절차로 수정.

현재 실행 순서는 로컬 MySQL 서비스 → 서버 `gradlew.bat bootRun` → 모바일 `npm start`이다.
각 팀원은 자신의 로컬 MySQL에서 초기화 스크립트를 실행하고 각자 `.env`를 사용한다.

## 초기 구축 당시 기록

검증일: 2026-10-12 (Asia/Seoul). 프로젝트 루트: `C:\NaengCook`.

## 생성 / 변경한 구성

- `apps/mobile`: create-expo-app 5.0.0의 공식 `default@sdk-57` 템플릿으로 생성.
  TypeScript strict, Expo Router, Android/iOS/Web 설정을 유지.
  Home 화면, `src/config/api.ts`, `.env.example`, ESLint 설정 및 typecheck 스크립트를 추가/변경.
  템플릿의 웹 hydration 훅을 useSyncExternalStore로 수정하고 CSS 타입 선언을 추가해 검사 오류 해결.
- `apps/server`: 공식 Initializr에서 기본 Java 프로젝트 생성. 현재 Initializr의 선택 목록에
  3.5.x가 없어 4.1.1 생성물을 바탕으로 **최종 결과를 3.5.16 의존성과 공식 Gradle 8.14.3 Wrapper로 변경**.
  실제 빌드와 실행에서도 Spring Boot 3.5.16을 확인.
  `com.capstone.fridgerecipe`, 서버 상태 API, local/prod 환경변수 설정, H2 테스트 구성.
- 루트: `.gitignore`, `.env.example`, `.nvmrc`, `compose.yaml`, `AGENTS.md`, README.
- `.env` 두 개와 `.tools`, `.local`은 이 PC의 로컬 파일이며 Git 추적에서 제외.
  루트 `.env`에는 무작위 생성한 로컬 DB 비밀번호를 사용. 실제 값은 보고서에 기록하지 않음.

## 버전

| 도구 / 의존성 | 실제 버전 |
| --- | --- |
| 기존 시스템 Node / npm | 20.20.2 / 10.8.2 |
| 프로젝트 내부 Node / npm | 24.21.0 LTS / 11.19.0 |
| create-expo-app / 템플릿 | 5.0.0 / 57.0.29 |
| Expo / Expo Router | 57.0.27 / 57.0.25 |
| React Native / React | 0.86.3 / 19.2.3 |
| TypeScript | 6.0.3 |
| ESLint / eslint-config-expo | 9.39.5 / 57.0.2 |
| 기존 Java / javac | Oracle JDK 21.0.11 |
| Spring Boot / Gradle | 3.5.16 / 8.14.3 |
| MySQL 설정 이미지 | mysql:8.4.11 (미실행) |
| 기존 Docker Client / Compose | 29.5.3 / 5.1.4 |
| Docker Desktop 로그상 버전 | 4.78.0 |
| 기존 Git | 2.54.0.windows.1 |

Git, JDK, Docker, VS Code, IntelliJ IDEA 2026.1.1과 Postman은 기존 설치를 확인했다.
시스템 전역 설치나 설정 변경은 수행하지 않았다. Node ZIP은 공식 배포 SHASUMS256으로 검증했다.
MySQL 이미지 버전은 Docker 공식 mysql 저장소의 versions.json에서 확인했다.

## 실행 결과

| 작업 / 명령 | 결과 |
| --- | --- |
| `npm install`, 이후 `npm ci` | 정상 설치, 잠금 파일을 통한 재설치 성공 |
| `npm run typecheck` | 최초 템플릿 CSS 타입 오류 수정 후 통과 |
| `npm run lint` | 최초 웹 hydration 훅 규칙 오류 수정 후 통과 |
| `npx expo install --check` | Dependencies are up to date |
| `npx expo-doctor` | 21/21 검사 통과 |
| `npx expo config --type public` | 정상 설정 출력 |
| `npx expo export --platform all` | Android/iOS/Web 번들 및 정적 웹 라우트 생성 성공 |
| `npx expo start --web --port 8081` | Metro 개발 서버 시작 성공 |
| 브라우저 기본 화면 | NaengCook, 한국어 안내와 API 주소 표시를 스크린샷으로 확인 |
| `gradlew.bat --version` | Gradle 8.14.3 / JVM 21.0.11 |
| `gradlew.bat clean build` | BUILD SUCCESSFUL, 테스트 2개, 실패/오류 0 |
| 서버 DB 제외 smoke 실행 | Tomcat 8080 시작 성공 |
| `Invoke-WebRequest http://localhost:8080/api/status` | HTTP 200, `{"status":"UP"}` |
| 일반 local 프로필 `gradlew.bat bootRun` | MySQL 통신 실패 / Connection refused로 시작 실패 |
| `docker compose config --quiet` | 통과 |
| `docker desktop start` | 엔진이 정상적으로 시작되지 않음 |
| `docker info`, `docker compose up -d --wait --wait-timeout 180` | Docker 엔진 named pipe 부재로 실패 |
| `git check-ignore` | 루트/모바일 .env, node_modules, 서버 build, .tools 제외 확인 |
| 예제 .env / 잠금 파일 / Wrapper 확인 | 무시되지 않음, 버전 관리 가능 |
| `git diff --check` | 통과 |
| 로컬 DB 비밀번호와 Git 후보 파일 대조 | 실제 비밀번호 포함 파일 없음 |

모바일 검증은 Node 24.21.0을 터미널의 임시 PATH에 적용하고 수행했다.
웹 화면을 확인했지만 실제 Android/iPhone의 Expo Go 실행은 기기 접근이 없어 수행하지 않았다.
네이티브 번들 생성 성공은 실제 기기 동작 확인과 구분한다.

DB 제외 smoke 실행의 정확한 명령 (서버 디렉터리):

```powershell
.\gradlew.bat bootRun --console=plain '--args=--spring.profiles.active=smoke --spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration'
```

이 명령은 HTTP 서버만 검증하기 위한 임시 실행이다. 평소 개발은 README의 local/MySQL 실행 방법을 사용한다.
테스트는 H2를 사용한다. **MySQL 컨테이너 실행, MySQL healthcheck, Spring Boot와 실제 MySQL 연결은 미검증이다.**
일반 local 프로필에서는 환경변수 구성을 읽고 MySQL 연결을 시도했으나 DB가 없어 Connection refused로 종료했다.
검증용 HTTP 서버, Metro 및 브라우저 탭은 확인 후 종료했다.

## Docker 실행 불가 원인과 후속 조치

Docker Desktop 시작 로그에 다음 오류가 있다:

```text
initializing Inference manager: listening on unix://C:/Users/user/AppData/Local/Docker/run/dockerInference:
The file cannot be accessed by the system.
listener: The filename, directory name, or volume label syntax is incorrect.
```

이후 Docker backend가 종료되어 `dockerDesktopLinuxEngine` named pipe가 생성되지 않았다.
WSL 기본 버전 2와 docker-desktop 배포판은 확인했다.
Docker Desktop 내부 오류이며 프로젝트 Compose 구문 오류와는 별개다.
사용자가 Docker Desktop 시작 오류를 해결한 뒤 루트에서 아래 순서로 남은 검증을 수행해야 한다.
Docker 데이터 삭제나 시스템 설정 변경은 수행하지 않았다.

```powershell
docker version
docker compose up -d --wait --wait-timeout 180
docker compose ps
cd apps/server
.\gradlew.bat bootRun
```

다른 터미널에서 `/api/status`를 확인하고 서버의 HikariPool MySQL 연결 로그를 확인한다.
MySQL의 업무용 테이블은 생성하지 않는다.

## 실제 의존성 경고

`npm audit --json` 결과 총 29건(중간 11, 높음 18, 치명적 0)의 의존성 경고가 있다.
대부분 Expo/Metro 관련 전이 의존성과 연결된 경고다. 자동 수정 제안에는 Expo 44로의 변경이나
Expo Router 58로의 변경이 포함되어 SDK 57 조합을 깨뜨릴 수 있어 강제 적용하지 않았다.
ESLint 9.39.5 지원 종료 경고도 확인했다. Expo 권장 설정의 버전 조합을 유지했다.
초기 환경 검사가 통과했다는 결과가 이 경고의 해결을 의미하지 않는다.
기능 개발/배포 전 팀에서 호환되는 공식 패치와 감사 결과를 재확인해야 한다.

## 팀원별 남은 설정과 다음 단계

4명 모두 JDK 21, Node 24.21.0, Docker Desktop을 준비하고 저장소를 Clone한다.
각자의 `.env`를 생성하고 모바일 API 주소를 자신의 PC LAN IP로 지정한다.
`npm ci`, MySQL healthy 확인, `gradlew build`, `bootRun`, Expo Go 기본 화면 확인을 수행한다.
공통 설정 변경은 README에 반영하고 기능 브랜치에서 PR로 병합한다.
다음 작업은 역할 분담 및 API 계약/데이터 모델 합의이며, 이번 작업에서는 기능을 구현하지 않았다.
