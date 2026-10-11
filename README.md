# NaengCook

캡스톤 디자인 1 프로젝트 공간입니다. 4인 팀이 개발하는 AI 기반 냉장고 식재료 관리 및
레시피 추천 모바일 앱입니다. 식재료 등록, 소비기한 관리와 임박 재료 우선 추천을 목표로 합니다.
현재 구현은 **초기 개발 환경과 `GET /api/status`**입니다.
인증, 식재료 CRUD, AI, 추천, 알림, 실제 DB 테이블은 아직 구현하지 않았습니다.

## 기술 스택 및 고정 버전

| 항목 | 버전 / 기준 |
| --- | --- |
| Node.js | 24.21.0 LTS (`.nvmrc`), Expo SDK 57 최소 요구는 22.13.x |
| npm | 11.19.0 (Node 24.21.0에 포함) |
| Expo | 57.0.27 / 공식 default SDK 57 템플릿 |
| React Native / React | 0.86.3 / 19.2.3 |
| Expo Router | 57.0.25 |
| TypeScript | 6.0.3 |
| ESLint / eslint-config-expo | 9.39.5 / 57.0.2 |
| Java | JDK 21 (검증 PC: 21.0.11) |
| Spring Boot | 3.5.16 |
| Gradle | 8.14.3, Wrapper로 자동 다운로드 |
| MySQL | 현재 로컬 설치 8.0.46 / 포트 3306 (Docker 도입은 후속 단계) |

모바일 의존성의 실제 패치 버전은 `apps/mobile/package-lock.json`으로 고정합니다.
팀원은 `npm ci`를 사용하며 SDK나 React Native를 개별적으로 업그레이드하지 않습니다.
Gradle은 별도 설치가 필요 없습니다. Wrapper 배포 파일의 SHA256을 검증합니다.
Spring Web, Data JPA, Validation, MySQL Driver, Boot Test를 사용합니다.
H2는 DB 없이 테스트하기 위한 **테스트 전용** 의존성입니다.

## 폴더 구조

```text
NaengCook/
├── apps/
│   ├── mobile/
│   │   ├── src/app/          # Expo Router 화면과 레이아웃
│   │   ├── src/config/       # 공개 API 주소
│   │   ├── src/components/   # 공식 템플릿 공통 UI
│   │   ├── assets/
│   │   ├── .env.example
│   │   └── package-lock.json
│   └── server/
│       ├── src/main/java/com/capstone/fridgerecipe/
│       ├── src/main/resources/   # 공통, local, prod 설정
│       ├── src/test/             # H2 컨텍스트 / 서버 상태 API 테스트
│       ├── gradle/wrapper/
│       └── build.gradle
├── docs/
├── compose.yaml
├── .env.example
├── .gitignore
├── .nvmrc
├── AGENTS.md
└── README.md
```

모바일 기본 Home 화면은 프로젝트 이름과 API 주소를 표시합니다.
공식 템플릿의 Explore 예제 화면과 UI 설정은 학습용으로 유지했습니다.

## 필수 설치 프로그램 (Windows)

1. Git, Node.js 24.21.0 LTS, JDK 21을 설치합니다.
2. MySQL Server를 직접 설치하고 서비스를 실행합니다. 현재 PC는 MySQL80 / 8.0.46입니다. Docker는 지금 필요하지 않습니다.
3. VS Code(모바일), IntelliJ IDEA(서버), Postman(API 테스트)를 준비합니다.
4. Android 또는 iPhone에 SDK 57을 지원하는 Expo Go를 설치합니다.

IntelliJ에서 `apps/server`를 열고 Project SDK와 Gradle JVM을 모두 JDK 21로 설정합니다.
VS Code에서는 `apps/mobile`을 열 수 있습니다. Android Studio는 에뮬레이터를 쓸 때만 필요합니다.
Windows에서는 iOS 시뮬레이터를 실행할 수 없으므로 실제 iPhone과 Expo Go로 확인합니다.
SDK 57 기준 Android 7 이상, iOS 16.4 이상이 필요합니다.

설치 확인:

```powershell
git --version
node --version
npm.cmd --version
java -version
javac -version
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --version
```

프로젝트 전용 Node는 `.tools/node-v24.21.0-win-x64`에 있으며 Git에 포함되지 않습니다.
루트의 `mobile.cmd`는 `.nvmrc`에 지정한 Node를 사용하므로 매번 PATH를 설정할 필요가 없습니다.
이 PC에는 이미 준비돼 있습니다. 팀원이 Clone한 뒤에는 아래 명령을 한 번 실행하세요.
공식 Node ZIP을 다운로드하고 SHA256을 검증하며 시스템 Node/PATH는 변경하지 않습니다.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup-node.ps1
.\mobile.cmd --node-version
```

## 팀원 4명 각각의 최초 설정

각자 저장소를 Clone하고 아래 작업을 수행합니다. `.env`와 DB 데이터는 각 PC에서 따로 관리합니다.
각 PC의 로컬 MySQL을 사용하므로 다른 팀원과 포트가 충돌하지 않습니다.

```powershell
git clone <팀 GitHub 저장소 URL> NaengCook
cd NaengCook
Copy-Item .env.example .env
Copy-Item apps/mobile/.env.example apps/mobile/.env
```

루트 `.env`의 `MYSQL_PASSWORD`를 프로젝트 전용 계정의 로컬 비밀번호로 변경합니다.
예제의 임시 문자열을 그대로 쓰지 마세요. `.env`를 팀원에게 보내거나 Git에 추가하지 않습니다.
서버가 읽을 수 있도록 `KEY=value` 형식을 사용합니다.
비밀번호는 영문/숫자로 설정하고 따옴표, `$`, `#`, 역슬래시를 피하면 파서 차이를 방지할 수 있습니다.

| 변수 | 용도 / 기본값 |
| --- | --- |
| MYSQL_DATABASE / MYSQL_USER | 로컬 DB 이름과 앱 계정: naengcook |
| MYSQL_PASSWORD | 프로젝트 전용 계정 비밀번호 (관리자 비밀번호는 저장하지 않음) |
| MYSQL_PORT | 로컬 MySQL 포트: 3306 |
| DB_HOST | 서버가 접근할 DB 호스트: 127.0.0.1 |
| SERVER_PORT | 백엔드 포트: 8080 |
| SPRING_PROFILES_ACTIVE | 로컬: local |
| SERVER_ADDRESS | 선택 사항, 기본 0.0.0.0 (LAN 접근 가능) |
| EXPO_PUBLIC_API_URL | 모바일 `.env`의 공개 API 주소 |

`EXPO_PUBLIC_*` 값은 앱에 포함되므로 AI API 키, 비밀번호, 토큰을 절대 넣지 않습니다.
운영 환경은 `SPRING_PROFILES_ACTIVE=prod`와 `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`를
외부 환경변수로 제공합니다. prod는 로컬 `.env`를 읽지 않습니다.

## 1. 로컬 MySQL 최초 설정 (루트 터미널)

MySQL Server가 설치돼 실행 중이어야 합니다. 이 PC의 서비스는 `MySQL80`, 포트는 `3306`입니다.
팀원도 가능하면 검증한 동일 버전 8.0.46을 사용합니다. 다른 버전은 먼저 호환성을 확인합니다.
관리자 root 계정 대신 프로젝트 전용 `naengcook` 계정을 서버에서 사용합니다.

```powershell
Get-Service MySQL80
powershell -ExecutionPolicy Bypass -File scripts/setup-local-mysql.ps1
```

스크립트가 요청할 때 **로컬 터미널에서** MySQL 관리자 비밀번호를 입력합니다.
비밀번호를 채팅, Git, 명령행 인수 또는 문서에 넣지 않습니다.
`ExecutionPolicy Bypass`는 해당 PowerShell 프로세스에만 적용되며 시스템 정책을 변경하지 않습니다.
스크립트는 `.env`를 읽어 DB와 localhost 전용 계정을 생성하고 해당 DB에만 권한을 부여합니다.
관리자 비밀번호는 일시적인 자식 프로세스 환경에 전달하며 파일에 저장하지 않습니다.
기존 프로젝트 계정이 있으면 비밀번호를 바꾸지 않으므로 `.env`에 그 계정의 기존 비밀번호를 설정합니다.
초기화용 비밀번호는 12자 이상의 영문/숫자/밑줄/하이픈을 사용하세요.

MySQL 설치 경로나 관리자 이름이 다르면:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup-local-mysql.ps1 -MySqlPath "D:\MySQL\bin\mysql.exe" -AdminUser root
```

DB는 `utf8mb4`와 `utf8mb4_0900_ai_ci`로 생성하며 업무용 테이블은 생성하지 않습니다.
데이터는 로컬 MySQL 서비스의 데이터 디렉터리에 저장됩니다.
이미 DB/계정이 준비돼 있으면 최초 설정은 다시 실행할 필요가 없습니다.

Docker는 개발 후 도입할 예정입니다. 기존 `compose.yaml`은 참고용으로 보존했으며 현재 실행 절차에 사용하지 않습니다.
향후 도입 시 별도 `.env.docker`와 `3307` 포트로 로컬 MySQL과 충돌하지 않게 구성하고 다시 검증합니다.

## 2. Spring Boot 실행 (별도 터미널)

항상 `apps/server`에서 실행합니다. local 설정은 이 작업 디렉터리를 기준으로 루트 `.env`를 읽습니다.

```powershell
cd apps/server
.\gradlew.bat clean build
.\gradlew.bat bootRun
```

macOS/Linux에서는 `chmod +x gradlew` 후 `./gradlew build`, `./gradlew bootRun`을 사용합니다.
첫 실행은 Gradle과 의존성 다운로드로 시간이 걸릴 수 있습니다.
JPA는 `ddl-auto=none`이므로 테이블을 자동 생성하지 않습니다.
DB 연결 성공은 시작 로그의 HikariPool 연결 및 EntityManagerFactory 초기화로 확인합니다.

다른 터미널 또는 Postman에서:

```powershell
Invoke-RestMethod http://localhost:8080/api/status
```

정상 응답은 HTTP 200과 `{"status":"UP"}`입니다. 이 API는 서버 실행 여부를 확인하며
DB 상태를 요청마다 검사하지 않습니다. DB 상태는 로컬 MySQL 서비스와 서버의 HikariPool 연결 로그를 함께 확인합니다.
서버 종료는 실행한 터미널에서 `Ctrl+C`입니다.

## 3. 모바일 실행 (별도 터미널)

Windows cmd 또는 IntelliJ 터미널에서는 프로젝트 루트에서 다음을 사용합니다.
PowerShell에서는 앞에 `.\`를 붙입니다. 작업 디렉터리는 자동으로 `apps/mobile`로 이동합니다.

```cmd
cd /d C:\NaengCook
mobile.cmd ci
mobile.cmd
```

`mobile.cmd`는 기본적으로 앱을 시작하며 `mobile.cmd run web`, `mobile.cmd run lint`,
`mobile.cmd run typecheck`처럼 npm 명령도 전달할 수 있습니다.
이 실행 파일 내부에서만 Node 버전을 적용합니다. 일반 `node` / `npm` 명령은 터미널의 기존 버전을 사용합니다.
IntelliJ의 npm 실행 구성에서도 사용할 경우 Node interpreter를 프로젝트의
`.tools/node-v24.21.0-win-x64/node.exe`로 지정하세요.

Node 24.21.0이 이미 적용된 터미널 또는 macOS/Linux에서는 기존 방식도 사용할 수 있습니다.

```powershell
cd apps/mobile
npm.cmd ci
npm.cmd start
```

PC와 휴대폰을 같은 Wi-Fi에 연결하고 Expo Go에서 QR 코드를 엽니다.
iPhone의 Expo Go가 로그인을 요구하면 Expo CLI와 동일한 Expo 계정으로 로그인합니다.
첫 화면에 NaengCook과 설정한 API 주소가 보이는지 확인합니다.

```powershell
npm.cmd run android  # Android 에뮬레이터가 준비된 경우
npm.cmd run web      # 브라우저에서 기본 화면 확인
```

### 실제 기기에서 백엔드 접근

`ipconfig`에서 현재 Wi-Fi/Ethernet 어댑터의 IPv4 주소를 확인합니다.
예를 들어 PC가 `192.168.0.10`이면 `apps/mobile/.env`를 다음과 같이 설정합니다.

```dotenv
EXPO_PUBLIC_API_URL=http://192.168.0.10:8080
```

휴대폰 브라우저에서 `http://192.168.0.10:8080/api/status`가 열리는지 먼저 확인합니다.
실제 기기에서 `localhost`는 휴대폰 자신입니다. Android 기본 에뮬레이터는 PC 대신 `10.0.2.2`를 사용합니다.
PC 웹 또는 macOS iOS 시뮬레이터는 `http://localhost:8080`을 사용할 수 있습니다.
값을 바꾼 뒤 앱을 완전히 새로고침하거나 Expo를 다시 실행합니다.
Windows 방화벽은 필요한 경우 신뢰하는 개인 네트워크에서만 Node와 서버의 접근을 허용합니다.
현재 기본 화면은 API 주소만 표시하며 자동 API 호출은 없습니다. 웹 API 호출의 CORS 설정은 후속 기능 개발 시 추가합니다.

## 검증 명령

모바일 디렉터리:

```powershell
npm.cmd run typecheck
npm.cmd run lint
npx.cmd expo install --check
npx.cmd expo-doctor
npx.cmd expo config --type public
npx.cmd expo export --platform all
```

서버 디렉터리:

```powershell
.\gradlew.bat --version
.\gradlew.bat clean build
```

H2 테스트는 컨텍스트 로딩과 서버 상태 API 응답을 검사합니다. 실제 MySQL 검증을 대신하지 않습니다.
이번 PC에서 수행한 결과와 미완료 항목은 `docs/verification.md`를 확인하세요.

## 자주 발생하는 오류

- **npm.ps1 실행 정책 오류**: PowerShell에서 `npm.cmd`, `npx.cmd`를 사용합니다.
- **Node 버전 오류**: `node --version`이 24.21.0인지 확인하고 터미널을 다시 엽니다.
- **MySQL 접속 실패**: `Get-Service MySQL80`과 3306 포트를 확인하고 최초 DB/계정 설정을 수행합니다. Docker 실행 여부와 무관합니다.
- **Java/Gradle 오류**: `javac -version`, IntelliJ Gradle JVM과 `JAVA_HOME`이 JDK 21을 가리키는지 확인합니다.
- **포트 충돌**: `.env`의 `MYSQL_PORT` 또는 `SERVER_PORT`를 바꿉니다. 서버 포트 변경 시 모바일 API 주소도 바꿉니다.
- **DB 연결 또는 비밀번호 오류**: MySQL 서비스 상태, `.env` 값, `apps/server` 작업 디렉터리와 기존 계정 비밀번호를 확인합니다.
- **Expo Go SDK 불일치**: SDK 57용 Expo Go를 공식 다운로드 페이지에서 설치합니다.
- **QR/서버 접속 실패**: 동일 Wi-Fi, LAN IP, VPN, 공유기 기기 간 격리와 방화벽을 확인합니다.
- **Metro 캐시 문제**: 모바일 디렉터리에서 `npx.cmd expo start --clear`를 실행합니다.
- **의존성 취약점 경고**: `npm audit`로 확인합니다. `npm audit fix --force`로 SDK를 임의 변경하지 말고 팀이 호환성을 검증합니다.

## Git 협업 원칙

`main`은 안정적인 코드만 유지합니다. 각 팀원은 별도 브랜치에서 작업하고 PR로 리뷰/병합합니다.
동일한 공통 파일을 동시에 변경할 때는 담당자를 먼저 조율합니다.

```powershell
git switch main
git pull --ff-only
git switch -c codex/작업이름
git status
git add <변경한 파일>
git commit -m "변경 내용"
git push -u origin codex/작업이름
```

잠금 파일과 Gradle Wrapper는 커밋합니다. `.env`, node_modules, 빌드 출력, 개인 IDE 설정은 제외합니다.
PR 전에 관련 검사와 `git diff --check`를 실행하고, 공통 설정 변경은 README에 기록합니다.
현재 GitHub Actions와 추가 브랜치 전략은 설정하지 않습니다.

## 공식 참고 자료

- [Expo 공식 프로젝트 생성](https://docs.expo.dev/get-started/create-a-project/)
- [Expo SDK 57 호환 버전](https://docs.expo.dev/versions/v57.0.0/)
- [Expo Go 다운로드](https://expo.dev/go)
- [Expo 환경변수](https://docs.expo.dev/guides/environment-variables/)
- [Spring Boot 3.5 요구사항](https://docs.spring.io/spring-boot/3.5/system-requirements.html)
- [MySQL Docker 공식 이미지](https://hub.docker.com/_/mysql)

다음 단계는 팀 역할 분담, API 계약과 데이터 모델 합의 후 작은 기능 단위로 구현하는 것입니다.
