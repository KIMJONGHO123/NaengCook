package com.capstone.fridgerecipe;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StatusController {
    @GetMapping("/api/status")
    public Map<String, String> serverStatus() {
        return Map.of("status", "UP");
    }
}
