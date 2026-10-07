package com.bookish.bookish.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
@Profile("cloud")
@ConditionalOnProperty(name = "app.database.initialize", havingValue = "true")
public class DeploymentDatabaseInitializer implements ApplicationRunner {
    private final DataSource dataSource;
    private final JdbcTemplate jdbc;
    private final PasswordEncoder passwordEncoder;
    private final String adminPassword;

    public DeploymentDatabaseInitializer(DataSource dataSource, PasswordEncoder passwordEncoder,
            @Value("${BOOTSTRAP_ADMIN_PASSWORD:}") String adminPassword) {
        this.dataSource = dataSource;
        this.jdbc = new JdbcTemplate(dataSource);
        this.passwordEncoder = passwordEncoder;
        this.adminPassword = adminPassword;
    }

    @Override
    public void run(ApplicationArguments args) {
        Integer existingTables = jdbc.queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()",
                Integer.class);
        // Never overwrite an existing database or reset existing account passwords.
        if (existingTables == null || existingTables > 0) return;

        new ResourceDatabasePopulator(new ClassPathResource("db/deploy-seed.sql"))
                .execute(dataSource);

        if (!adminPassword.isBlank()) {
            jdbc.update("INSERT INTO users (username, password, role, email_verified, created_at) "
                            + "VALUES (?, ?, 'ADMIN', 1, CURRENT_TIMESTAMP)",
                    "admin", passwordEncoder.encode(adminPassword));
        }
    }
}
