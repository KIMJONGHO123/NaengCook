package com.capstone.fridgerecipe;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class SchemaMigrationTests {

	@Autowired
	JdbcTemplate jdbc;

	@Test
	void flywayCreatesAllTables() {
		List<String> tables = jdbc.queryForList(
			"SELECT LOWER(table_name) FROM information_schema.tables WHERE LOWER(table_schema) = 'public'",
			String.class);

		assertThat(tables).contains(
			"users",
			"ingredients",
			"ingredient_aliases",
			"user_ingredients",
			"recipes",
			"recipe_ingredients");
	}

}
