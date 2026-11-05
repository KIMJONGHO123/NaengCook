# NaengCook API 명세 (MVP 초안 v0.2)

작성일 2026-11-04, 수정일 2026-11-06. 프론트/백엔드 공통 계약 문서. 구현 전 설계 단계이며 실제 코드·엔티티·스키마는 포함하지 않는다.

## 전제
- **단일 사용자** 가정: 인증/회원가입은 MVP에서 제외(후속 단계). 냉장고는 1개로 본다.
- 레시피 추천은 **DB/규칙 기반**(AI 아님). 추천 계산 방식은 [`recommendation-design.md`](./recommendation-design.md) 참고.
- 아래 요청/응답 형태는 프론트가 목(mock) 데이터로 선개발할 수 있도록 고정한 **계약**이다.

## 공통 규약
- Base URL: `http://localhost:8080/api`
- 요청·응답 모두 JSON (`Content-Type: application/json`)
- 필드명 camelCase, 날짜는 `YYYY-MM-DD`
- 기존 헬스체크 `GET /api/status` 는 이미 존재(`{"status":"UP"}`).

## 기능 / 범위

| 기능 | MVP | 비고 |
|---|---|---|
| 냉장고 재료 CRUD | O | 핵심 |
| 유통기한 표시/정렬 | O | 앱 내 표시 수준. 푸시 알림은 제외 |
| 레시피 추천 (DB/규칙 기반) | O | 설계는 별도 문서 |
| 사용자 인증 | X (후속) | 단일 사용자 가정으로 시작 |
| 유통기한 푸시 알림 | X (후속) | 인증 도입 이후가 자연스러움 |

---

## 1. 재료 (Ingredients)

### `GET /ingredients` — 재료 목록
쿼리: `?sort=expiry`(유통기한 임박순, 기본값) / `?sort=created`(등록순)

```json
[
  {
    "id": 1,
    "name": "계란",
    "quantity": 10,
    "unit": "개",
    "category": "유제품/난류",
    "expirationDate": "2026-11-20",
    "daysLeft": 16,
    "createdAt": "2026-11-04"
  }
]
```
- `daysLeft`는 서버가 계산해 내려준다(음수면 유통기한 지남). 프론트는 이 값으로 색/정렬 표시.

### `POST /ingredients` — 재료 추가
```json
// 요청
{ "name": "우유", "quantity": 1, "unit": "L", "category": "유제품/난류", "expirationDate": "2026-11-10" }
```
- 응답 `201` + 생성된 객체(GET 항목과 동일 형태).
- `category`는 선택(없으면 null 허용). 나머지는 필수.
- `name`이 기준 재료 목록에 없으면 서버가 기준 재료를 새로 추가한 뒤 저장한다. 앱의 "직접 추가"가 이 경우에 해당한다.
- `expirationDate`는 앱이 관리하는 날짜이며, 제품에 표시된 날짜와 다를 수 있다. `daysLeft`와 임박 판정의 기준이다.

### `PUT /ingredients/{id}` — 재료 수정
- 요청 바디는 POST와 동일, 응답 `200` + 수정된 객체.

### `DELETE /ingredients/{id}` — 재료 삭제
- 응답 `204` (바디 없음).

### `GET /ingredient-master` — 기준 재료 검색 (자동완성)
쿼리: `?query=계` (필수, 재료명과 별칭의 부분 일치)

```json
[
  { "id": 1, "name": "계란", "category": "유제품/난류", "defaultUnit": "개", "defaultDays": 14 }
]
```
- 재료 등록 화면의 자동완성에 사용한다. 최대 10개를 반환하고, 일치하는 재료가 없으면 `[]`를 반환한다.
- 앱은 재료를 고르면 날짜 칸을 `오늘 + defaultDays`로 미리 채운다. 직접 추가된 재료처럼 값이 없으면 `null`이며, 사용자가 날짜를 입력한다.
- 앱은 결과가 없을 때 "직접 추가"를 보여주고, 사용자가 누르면 입력한 이름으로 `POST /ingredients`를 호출한다.

---

## 2. 레시피 (Recipes)

### `GET /recipes` — 레시피 목록
```json
[
  {
    "id": 1,
    "name": "계란볶음밥",
    "ingredients": [
      { "name": "계란", "quantity": 2, "unit": "개" },
      { "name": "밥", "quantity": 1, "unit": "공기" }
    ],
    "steps": ["밥을 볶는다", "계란을 넣는다"]
  }
]
```

### `GET /recipes/{id}` — 레시피 상세
- 위 목록의 단일 객체(`200`).

> MVP 레시피 데이터는 테스트용 목업(약 30개)으로 시작한다. 실제 데이터 출처는 추후 결정.

---

## 3. 추천 (Recommendations)

### `GET /recommendations` — 현재 보유 재료로 추천
- 보유 재료는 서버가 이미 알고 있으므로 **입력 없음**.
- 추천 점수 내림차순 정렬. 점수·제외·감점 규칙은 [`recommendation-design.md`](./recommendation-design.md).

```json
[
  {
    "recipe": { "id": 1, "name": "계란볶음밥" },
    "score": 5.0,
    "ownedIngredients": ["계란", "밥"],
    "missingIngredients": [],
    "expiringIngredientsUsed": ["계란"],
    "matchedCount": 2,
    "totalCount": 2
  },
  {
    "recipe": { "id": 5, "name": "김치찌개" },
    "score": 4.5,
    "ownedIngredients": ["김치", "대파", "돼지고기"],
    "missingIngredients": ["두부"],
    "expiringIngredientsUsed": ["대파"],
    "matchedCount": 3,
    "totalCount": 4
  }
]
```
설명용 필드(정책: 추천 결과 설명):
- `ownedIngredients` — 레시피의 필수 재료 중 보유한 재료
- `missingIngredients` — 필수 재료 중 부족한 재료. 선택 재료는 포함하지 않는다.
- `expiringIngredientsUsed` — 임박 재료 중 이 레시피가 실제로 쓰는 것(= 임박 활용 여부). 필수·선택 재료를 모두 포함한다.
- `matchedCount` / `totalCount` — 보유한 필수 재료 수 / 전체 필수 재료 수
- 예시의 `score`는 `3 × 임박 재료 수 + 2 × (matchedCount ÷ totalCount)`로 계산한 값이다(5.0 = 3 + 2, 4.5 = 3 + 1.5).

---

## 공통: 에러 응답
전 엔드포인트 공통 형식:
```json
{ "message": "재료를 찾을 수 없습니다", "status": 404 }
```
상태 코드: `200` 성공 / `201` 생성 / `204` 삭제 / `400` 잘못된 요청 / `404` 없음

---

## 변경 이력 (v0.1 → v0.2)

| 항목 | 기존 | 변경 | 이유 |
|---|---|---|---|
| 추천 예시의 김치찌개 | 보유 2개, 부족 2개(`돼지고기`, `두부`) | 보유 3개, 부족 1개(`두부`) | 부족 50%는 제외 대상이라 추천 결과에 나올 수 없다. |
| 재료 자동완성 | API 없음 | `GET /ingredient-master` 추가 | 재료를 목록에서 골라 오타를 줄인다. |
| 목록에 없는 재료 | 처리 규칙 없음 | "직접 추가" 시 서버가 기준 재료를 추가한 뒤 저장 | 목록에 없는 재료도 등록할 수 있어야 한다. |
| 자동완성 응답 | `defaultDays` 없음 | `defaultDays` 추가 | 앱이 날짜 칸을 미리 채우는 데 필요하다. |
| `expirationDate`의 의미 | 어떤 날짜인지 정의 없음 | 앱이 관리하는 날짜(`management_date`) | `daysLeft`와 임박 판정의 기준을 하나로 정한다. |
| 추천 재료 필드의 기준 | 레시피의 모든 재료 | 부족·일치 수는 필수 재료 기준 | 양념 때문에 레시피가 제외되는 문제를 막는다. |
| 추천 `score` 예시 | 87.5, 52.0 | 5.0, 4.5 | 확정한 점수 계산 방식에 맞췄다. |
