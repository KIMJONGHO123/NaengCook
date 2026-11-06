# NaengCook DB 설계 (MVP 초안 v0.2)

작성일 2026-11-05, 수정일 2026-11-06. 구현 전 설계 문서이며 아래 DDL은 아직 실행하지 않았다.
초기 설계안의 5개 테이블을 기준으로, [`api-spec.md`](./api-spec.md)와 [`recommendation-design.md`](./recommendation-design.md)를 구현하는 데 필요한 내용을 보완했다.
추천 정책은 초기 설계안이 아니라 `recommendation-design.md`를 기준으로 한다.

## 테이블 관계

```
users (1) ──< user_ingredients >── (1) ingredients (1) ──< recipe_ingredients >── (1) recipes
                                         │
                                         └──< ingredient_aliases
```

| 테이블 | 역할 |
|---|---|
| `users` | 사용자. MVP는 시드 사용자 1명으로 운영한다. |
| `ingredients` | 식재료 기준 정보(마스터). 추천 매칭의 기준이다. |
| `ingredient_aliases` | 별칭 사전. 입력된 재료명을 기준 재료로 정규화한다. |
| `user_ingredients` | 사용자가 보유한 식재료. API의 `/ingredients`가 다루는 데이터다. |
| `recipes` | 레시피. |
| `recipe_ingredients` | 레시피별 필요 재료. |

## 원본 설계안에서 보완한 내용

| 대상 | 변경 | 이유 |
|---|---|---|
| `ingredient_aliases` | 테이블 추가 | 별칭 사전을 코드가 아닌 데이터로 관리하기로 했다. |
| `user_ingredients.unit` | 컬럼 추가 | API가 재료별 `unit`을 주고받으며, 기본 단위와 다를 수 있다. |
| `user_ingredients.category` | 컬럼 추가 | 사용자가 분류를 바꿔도 공용 마스터가 바뀌면 안 된다. |
| `user_ingredients.created_at` | 컬럼 추가 | API 응답의 `createdAt`, `?sort=created`에 필요하다. |
| `recipe_ingredients.quantity`, `unit` | 컬럼 추가 | 레시피 API가 재료별 수량과 단위를 응답한다. |
| `user_ingredients.status` | 컬럼 제거 | 삭제는 행을 바로 지우고 임박 여부는 계산하므로 MVP에서 쓸 곳이 없다. |

## DDL 초안

```sql
CREATE TABLE users (
  id       BIGINT       NOT NULL AUTO_INCREMENT,
  email    VARCHAR(255) NULL,
  nickname VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ingredients (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100) NOT NULL,
  category      VARCHAR(50)  NULL,
  default_days  INT          NULL,
  default_unit  VARCHAR(20)  NULL,
  storage_guide VARCHAR(500) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_ingredients_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ingredient_aliases (
  alias         VARCHAR(100) NOT NULL,
  ingredient_id BIGINT       NOT NULL,
  PRIMARY KEY (alias),
  CONSTRAINT fk_aliases_ingredient
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_ingredients (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  user_id         BIGINT        NOT NULL,
  ingredient_id   BIGINT        NOT NULL,
  quantity        DECIMAL(10,2) NOT NULL,
  unit            VARCHAR(20)   NOT NULL,
  category        VARCHAR(50)   NULL,
  storage_type    VARCHAR(20)   NULL,
  purchase_date   DATE          NULL,
  expiry_date     DATE          NULL,
  management_date DATE          NOT NULL,
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_ingredients_user_date (user_id, management_date),
  CONSTRAINT fk_user_ingredients_user
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_user_ingredients_ingredient
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recipes (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  name         VARCHAR(200) NOT NULL,
  instructions TEXT         NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recipe_ingredients (
  recipe_id     BIGINT        NOT NULL,
  ingredient_id BIGINT        NOT NULL,
  quantity      DECIMAL(10,2) NULL,
  unit          VARCHAR(20)   NULL,
  is_required   BOOLEAN       NOT NULL DEFAULT TRUE,
  PRIMARY KEY (recipe_id, ingredient_id),
  KEY idx_recipe_ingredients_ingredient (ingredient_id),
  CONSTRAINT fk_recipe_ingredients_recipe
    FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
  CONSTRAINT fk_recipe_ingredients_ingredient
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## API 매핑

### `/ingredients` ↔ `user_ingredients`

| API 필드 | DB | 비고 |
|---|---|---|
| `id` | `user_ingredients.id` | 보유 기록의 ID다. 마스터 ID가 아니다. |
| `name` | `ingredients.name` | 별칭을 거쳐 정규화한 이름을 응답한다. |
| `quantity`, `unit` | `user_ingredients.quantity`, `unit` | 소수 수량(예: 1.5L)을 허용한다. |
| `category` | `user_ingredients.category` | 값이 없으면 `ingredients.category`를 사용한다. |
| `expirationDate` | `user_ingredients.management_date` | 앱이 관리하는 날짜다. `expiry_date`는 MVP에서 비워 둔다. |
| `daysLeft` | 저장하지 않음 | `management_date - 오늘(Asia/Seoul)`로 계산한다. |
| `createdAt` | `user_ingredients.created_at` | 응답은 `YYYY-MM-DD`로 변환한다. |

### `/recipes` ↔ `recipes`, `recipe_ingredients`

| API 필드 | DB | 비고 |
|---|---|---|
| `ingredients[].name` | `ingredients.name` | `recipe_ingredients`와 조인한다. |
| `ingredients[].quantity`, `unit` | `recipe_ingredients.quantity`, `unit` | "약간"처럼 수량이 없으면 NULL이다. |
| `ingredients[].isRequired` | `recipe_ingredients.is_required` | 필수 재료 여부다. |
| `steps` | `recipes.instructions` | 단계를 줄바꿈으로 저장하고 응답 시 배열로 나눈다. |

## 동작 규칙

- **단일 사용자:** 인증 전까지 시드 사용자 1명의 `user_id`를 서버에서 고정해 사용한다. 인증을 도입해도 테이블 구조는 유지된다.
- **재료명 저장:** `POST`/`PUT`의 `name`은 별칭 사전과 `ingredients.name`을 거쳐 `ingredient_id`로 변환한다.
- **재료 선택과 직접 추가:** 앱은 자동완성(`GET /ingredient-master`)으로 기준 재료를 고르게 한다. 목록에 없는 재료는 사용자가 "직접 추가"를 누르면 이름만 있는 `ingredients` 행을 만들어 연결한다.
- **추천 매칭:** 재료명 문자열이 아니라 `ingredient_id`의 일치 여부로 판단한다. 대체 재료는 인정하지 않는다.
- **중복 보유:** 같은 재료를 날짜가 다르게 여러 건 보유할 수 있으므로 `(user_id, ingredient_id)`를 UNIQUE로 두지 않는다. 추천에서는 재료 1개로 세고, 임박 판정에는 가장 빠른 `management_date`를 사용한다.
- **관리 날짜:** 기준 재료를 고르면 앱이 날짜 칸을 `오늘 + default_days`로 미리 채우고, 사용자가 확인하거나 고친 값을 저장한다. 직접 추가한 재료는 사용자가 날짜를 입력한다.
- **관리 날짜 변경:** 분류나 보관 방식을 바꿔도 다시 계산하지 않는다. 사용자가 날짜를 직접 수정할 때만 바뀐다.
- **필수 재료:** 기본 양념과 없어도 되는 재료는 `is_required = FALSE`로 넣는다. 레시피마다 필수 재료를 1개 이상 둔다. 추천 계산 규칙은 `recommendation-design.md`를 따른다.
- **분류 값:** `category`와 `storage_type`은 DB ENUM 대신 문자열로 저장하고 애플리케이션에서 검증한다. `category`의 허용 값은 `api-spec.md`를 따른다.
- **MVP 미사용 컬럼:** `storage_type`, `purchase_date`는 MVP API에서 입력받지 않으므로 NULL로 둔다. 후속 기능을 위해 컬럼은 유지한다.
- **테이블 구조:** `category`와 `default_unit`은 별도 테이블로 나누지 않고 컬럼으로 유지한다.
- **스키마 적용:** `ddl-auto=none`을 유지하고, 구현 시 Flyway 마이그레이션 파일(`V1__init.sql` 등)을 커밋해 팀원의 로컬 DB를 맞춘다. 테스트는 H2를 쓰므로 Flyway 처리 방식을 함께 설정한다.
- **재료 삭제:** `ingredients` 행이 보유 기록이나 레시피에서 쓰이는 동안에는 삭제할 수 없다.

## 변경 이력 (v0.1 → v0.2)

| 항목 | 기존 | 변경 | 이유 |
|---|---|---|---|
| `expirationDate` 연결 | 어떤 날짜인지 미정. 임시로 `management_date`에 저장 | `management_date`로 확정. 날짜 칸을 `오늘 + default_days`로 미리 채우고 사용자가 확인 | 날짜가 인쇄되지 않은 재료도 관리할 수 있다. |
| `status` | `ACTIVE`만 쓰는 컬럼으로 유지 | 컬럼 제거 | MVP에서 쓸 곳이 없다. 소비 이력 기능이 생길 때 추가한다. |
| `is_required` | 시드를 모두 `TRUE`로 입력 | 기본 양념과 없어도 되는 재료는 `FALSE`, 추천은 필수 재료만 계산 | 양념이 없다는 이유로 레시피가 제외되는 문제를 막는다. |
| 스키마 적용 방식 | Flyway 같은 도구 도입을 검토 | Flyway 사용 | 팀원 4명의 로컬 DB를 같은 구조로 맞출 수 있다. |
| 목록에 없는 재료 | 입력하면 `ingredients` 행을 자동 생성 | 자동완성에서 고르고, 없으면 "직접 추가"를 눌러 생성 | 오타가 새 재료로 저장되는 일을 줄인다. |
| 분류/단위 테이블 | 분리 여부 미정 | 분리하지 않고 컬럼으로 유지 | MVP 범위에서는 컬럼으로 충분하다. |
| 추천 제외 기준 | 초기 설계안: 부족 5개 이상 | `recommendation-design.md`의 부족 50% 이상 | 이전 계획이며 추천 설계 문서를 기준으로 삼는다. |
| `storage_type`, `purchase_date` | 사용 범위 미정 | MVP에서는 입력받지 않고 NULL로 유지 | API v1.0 결정에 맞췄다. |
| `category` 검증 | 규칙 없음 | `api-spec.md`의 고정 목록으로 애플리케이션에서 검증 | API v1.0 결정에 맞췄다. |
