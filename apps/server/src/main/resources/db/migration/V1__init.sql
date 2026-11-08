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
