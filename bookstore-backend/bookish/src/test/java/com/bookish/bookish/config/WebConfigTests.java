package com.bookish.bookish.config;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.MapPropertySource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mock.web.MockServletContext;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class WebConfigTests {
    @TempDir Path uploads;

    @Configuration
    @EnableWebMvc
    static class TestConfiguration implements WebMvcConfigurer {
        @Value("${test.upload-dir}") String uploadDirectory;

        @Override
        public void addResourceHandlers(ResourceHandlerRegistry registry) {
            var config = new WebConfig();
            ReflectionTestUtils.setField(config, "uploadDir", uploadDirectory);
            config.addResourceHandlers(registry);
        }
    }

    @Test
    void servesCoversFromConfiguredDirectoryIncludingPathsWithSpaces() throws Exception {
        Path directory = uploads.resolve("catalog covers");
        Files.createDirectories(directory);
        try (var input = new ClassPathResource("covers/dac_nhan_tam.jpg").getInputStream()) {
            Files.copy(input, directory.resolve("cover.jpg"));
        }
        byte[] expectedImage = Files.readAllBytes(directory.resolve("cover.jpg"));
        try (var context = new AnnotationConfigWebApplicationContext()) {
            context.setServletContext(new MockServletContext());
            context.getEnvironment().getPropertySources().addFirst(new MapPropertySource(
                    "test", Map.of("test.upload-dir", directory.toString())));
            context.register(TestConfiguration.class);
            context.refresh();
            var mvc = MockMvcBuilders.webAppContextSetup(context).build();
            mvc.perform(get("/uploads/cover.jpg"))
                    .andExpect(status().isOk())
                    .andExpect(content().contentType("image/jpeg"))
                    .andExpect(content().bytes(expectedImage));
            mvc.perform(get("/uploads/missing.jpg")).andExpect(status().isNotFound());
        }
    }
}
