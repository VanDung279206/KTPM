package com.bookish.bookish.security;

import com.bookish.bookish.entity.Role;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class JwtUtilTests {
    @Test
    void tokenSurvivesRestartWithConfiguredKeyButCannotUseAnotherKey() {
        String secret = "test-signing-key-for-deployment-at-least-32-bytes";
        JwtUtil issuer = new JwtUtil(secret);
        String token = issuer.generateToken("demo", Role.USER, 42);
        JwtUtil restarted = new JwtUtil(secret);

        assertTrue(restarted.validateToken(token));
        assertEquals("demo", restarted.extractUsername(token));
        assertEquals(42, restarted.extractUserId(token));
        assertEquals("USER", restarted.extractRole(token));
        assertFalse(new JwtUtil("another-test-signing-key-at-least-32-bytes").validateToken(token));
    }
}
