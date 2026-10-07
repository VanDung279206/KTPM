package com.bookish.bookish.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;

/** Restores bundled catalog covers without overwriting merchant uploads. */
@Component
@Profile("cloud")
@Slf4j
public class DeploymentCoverInitializer implements ApplicationRunner {
    private final Path uploadDirectory;

    public DeploymentCoverInitializer(@Value("${upload.dir:uploads}") String uploadDirectory) {
        this.uploadDirectory = Path.of(uploadDirectory).toAbsolutePath().normalize();
    }

    @Override
    public void run(ApplicationArguments args) throws IOException {
        Files.createDirectories(uploadDirectory);
        int restored = 0;
        var resources = new PathMatchingResourcePatternResolver().getResources("classpath*:covers/*.jpg");
        for (var resource : resources) {
            String filename = resource.getFilename();
            if (filename == null || !filename.matches("[A-Za-z0-9_]+\\.jpg")) {
                throw new IOException("Invalid bundled cover filename");
            }
            Path destination = uploadDirectory.resolve(filename).normalize();
            if (!destination.getParent().equals(uploadDirectory)) {
                throw new IOException("Cover path is outside upload directory");
            }
            try (var input = resource.getInputStream()) {
                // Files.copy without REPLACE_EXISTING also protects existing symlinks.
                Files.copy(input, destination);
                restored++;
            } catch (FileAlreadyExistsException ignored) {
                // A cover already uploaded by the merchant takes precedence.
            }
        }
        log.info("Restored {} missing catalog covers", restored);
    }
}
