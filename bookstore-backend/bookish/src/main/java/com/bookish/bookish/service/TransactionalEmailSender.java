package com.bookish.bookish.service;

import com.bookish.bookish.exception.AppException;
import com.bookish.bookish.exception.ErrorCode;
import jakarta.mail.internet.MimeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@Component
@Slf4j
public class TransactionalEmailSender {
    private static final String BREVO_URL = "https://api.brevo.com/v3/smtp/email";
    private final JavaMailSender smtp;
    private final RestTemplate httpClient;
    private final String provider;
    private final String apiKey;
    private final String fromEmail;
    private final String fromName;
    private final String smtpFrom;

    public TransactionalEmailSender(JavaMailSender smtp,
            @Value("${app.mail.provider:smtp}") String provider,
            @Value("${brevo.api.key:}") String apiKey,
            @Value("${app.mail.from-email:}") String fromEmail,
            @Value("${app.mail.from-name:Bookish}") String fromName,
            @Value("${app.mail.from:Bookish <noreply@example.com>}") String smtpFrom) {
        this.smtp = smtp;
        this.provider = provider;
        this.apiKey = apiKey;
        this.fromEmail = fromEmail;
        this.fromName = fromName;
        this.smtpFrom = smtpFrom;
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(10_000);
        factory.setReadTimeout(15_000);
        this.httpClient = new RestTemplate(factory);
    }

    public void send(String recipient, String subject, String html) {
        try {
            if ("brevo".equalsIgnoreCase(provider)) {
                if (apiKey.isBlank() || fromEmail.isBlank()) {
                    throw new IllegalStateException("Email provider configuration is incomplete");
                }
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                headers.setAccept(List.of(MediaType.APPLICATION_JSON));
                headers.set("api-key", apiKey);
                Map<String, Object> body = Map.of(
                        "sender", Map.of("email", fromEmail, "name", fromName),
                        "to", List.of(Map.of("email", recipient)),
                        "subject", subject,
                        "htmlContent", html);
                ResponseEntity<Map> response = httpClient.postForEntity(
                        BREVO_URL, new HttpEntity<>(body, headers), Map.class);
                if (response.getBody() == null || !response.getBody().containsKey("messageId")) {
                    throw new IllegalStateException("Email provider did not accept the message");
                }
            } else if ("smtp".equalsIgnoreCase(provider)) {
                MimeMessage message = smtp.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message,
                        MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED, StandardCharsets.UTF_8.name());
                helper.setFrom(smtpFrom);
                helper.setTo(recipient);
                helper.setSubject(subject);
                helper.setText(html, true);
                smtp.send(message);
            } else {
                throw new IllegalStateException("Unsupported email provider");
            }
        } catch (RestClientResponseException e) {
            // Provider response bodies may contain addresses or codes; never log them.
            log.warn("Email delivery rejected by provider (HTTP {})", e.getStatusCode().value());
            throw new AppException(ErrorCode.EMAIL_SEND_FAILED);
        } catch (Exception e) {
            log.warn("Email delivery failed ({})", e.getClass().getSimpleName());
            throw new AppException(ErrorCode.EMAIL_SEND_FAILED);
        }
    }
}
