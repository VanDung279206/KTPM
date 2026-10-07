package com.bookish.bookish.service;

import com.bookish.bookish.exception.AppException;
import com.bookish.bookish.exception.ErrorCode;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

class TransactionalEmailSenderTests {
    private TransactionalEmailSender configuredSender() {
        return new TransactionalEmailSender(null, "brevo", "test-api-key",
                "sender@example.com", "Bookish", "");
    }

    private MockRestServiceServer serverFor(TransactionalEmailSender sender) {
        return MockRestServiceServer.bindTo(
                (RestTemplate) ReflectionTestUtils.getField(sender, "httpClient")).build();
    }

    @Test
    void sendsVerificationHtmlToBrevoOverHttps() {
        var sender = configuredSender();
        var server = serverFor(sender);
        server.expect(requestTo("https://api.brevo.com/v3/smtp/email"))
                .andExpect(method(HttpMethod.POST))
                .andExpect(header("api-key", "test-api-key"))
                .andExpect(content().json("""
                        {"sender":{"email":"sender@example.com","name":"Bookish"},
                         "to":[{"email":"customer@example.com"}],
                         "subject":"Verify", "htmlContent":"<p>123456</p>"}
                        """))
                .andRespond(withStatus(HttpStatus.CREATED).contentType(MediaType.APPLICATION_JSON)
                        .body("{\"messageId\":\"accepted@example.com\"}"));
        sender.send("customer@example.com", "Verify", "<p>123456</p>");
        server.verify();
    }

    @Test
    void rejectsMissingConfigurationWithoutFallingBackToSmtp() {
        var sender = new TransactionalEmailSender(null, "brevo", "", "", "Bookish", "");
        AppException error = assertThrows(AppException.class,
                () -> sender.send("customer@example.com", "Verify", "123456"));
        assertEquals(ErrorCode.EMAIL_SEND_FAILED, error.getErrorCode());
    }

    @Test
    void providerFailureIsReportedToRegistration() {
        var sender = configuredSender();
        var server = serverFor(sender);
        server.expect(requestTo("https://api.brevo.com/v3/smtp/email"))
                .andRespond(withStatus(HttpStatus.TOO_MANY_REQUESTS)
                        .body("private provider diagnostic"));
        AppException error = assertThrows(AppException.class,
                () -> sender.send("customer@example.com", "Verify", "123456"));
        assertEquals(ErrorCode.EMAIL_SEND_FAILED, error.getErrorCode());
        assertFalse(error.toString().contains("private provider diagnostic"));
        server.verify();
    }

    @Test
    void responseWithoutMessageIdDoesNotClaimDelivery() {
        var sender = configuredSender();
        var server = serverFor(sender);
        server.expect(requestTo("https://api.brevo.com/v3/smtp/email"))
                .andRespond(withSuccess("{}", MediaType.APPLICATION_JSON));
        assertThrows(AppException.class,
                () -> sender.send("customer@example.com", "Verify", "123456"));
        server.verify();
    }

    @Test
    void usernameIsEscapedAndOtpIsExcludedFromSubject() {
        class CapturingSender extends TransactionalEmailSender {
            String subject;
            String html;
            CapturingSender() { super(null, "brevo", "", "", "Bookish", ""); }
            @Override public void send(String to, String subject, String html) {
                this.subject = subject;
                this.html = html;
            }
        }
        var sender = new CapturingSender();
        new EmailService(sender).sendVerificationCode("customer@example.com", "<b>A</b>", "123456");
        assertTrue(sender.html.contains("&lt;b&gt;A&lt;/b&gt;"));
        assertTrue(sender.html.contains("123456"));
        assertFalse(sender.subject.contains("123456"));
    }
}
