package com.bookish.bookish.config;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.*;

class DeploymentCoverInitializerTests {
    @TempDir Path temporaryDirectory;

    @Test
    void restoresCatalogAndPreservesUploadedCoverAcrossRestarts() throws Exception {
        Path uploads = temporaryDirectory.resolve("uploads");
        Files.createDirectories(uploads);
        Path merchantCover = uploads.resolve("nha_gia_kim.jpg");
        byte[] merchantImage = "merchant's replacement image".getBytes();
        Files.write(merchantCover, merchantImage);

        var initializer = new DeploymentCoverInitializer(uploads.toString());
        initializer.run(null);
        initializer.run(null);

        assertArrayEquals(merchantImage, Files.readAllBytes(merchantCover));
        try (var files = Files.list(uploads)) {
            assertEquals(18, files.filter(path -> path.toString().endsWith(".jpg")).count());
        }
        byte[] restored = Files.readAllBytes(uploads.resolve("dac_nhan_tam.jpg"));
        assertEquals(0xff, restored[0] & 0xff);
        assertEquals(0xd8, restored[1] & 0xff);
        assertTrue(restored.length > 1000);
    }
}
