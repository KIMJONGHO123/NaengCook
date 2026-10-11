package com.capstone.fridgerecipe;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
class FridgeRecipeApplicationTests {

	@Autowired
	MockMvc mvc;

	@Test
	void contextLoads() {
	}

	@Test
	void statusReturnsUp() throws Exception {
		mvc.perform(get("/api/status"))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.status").value("UP"));
	}

}
