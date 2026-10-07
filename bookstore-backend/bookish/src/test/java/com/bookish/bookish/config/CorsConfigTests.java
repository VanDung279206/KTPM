package com.bookish.bookish.config;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;

import static org.junit.jupiter.api.Assertions.*;

class CorsConfigTests {
    @Test
    void configuredWebsiteCanCallApiButOtherWebsitesCannot() {
        CorsConfig config = new CorsConfig("https://bookish.example, http://localhost:3000");
        var policy = config.corsConfigurationSource()
                .getCorsConfiguration(new MockHttpServletRequest("GET", "/books"));

        assertNotNull(policy);
        assertEquals("https://bookish.example", policy.checkOrigin("https://bookish.example"));
        assertNull(policy.checkOrigin("https://untrusted.example"));
        assertEquals(Boolean.TRUE, policy.getAllowCredentials());
        assertArrayEquals(new String[]{"https://bookish.example", "http://localhost:3000"}, config.allowedOrigins());
    }
}
