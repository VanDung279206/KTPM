package com.bookish.bookish.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.util.HtmlUtils;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final TransactionalEmailSender mailSender;

    /**
     * Gửi mã xác thực 6 chữ số tới email của user.
     */
    public void sendVerificationCode(String toEmail, String username, String code) {
        String subject = "Mã xác thực tài khoản Bookish";
        String html = buildCodeHtml(username, code);
        mailSender.send(toEmail, subject, html);
    }

    public void sendResetPasswordCode(String toEmail, String username, String code) {
        String subject = "Đặt lại mật khẩu Bookish";
        String html = buildResetPasswordHtml(username, code);
        mailSender.send(toEmail, subject, html);
    }

    private String buildResetPasswordHtml(String username, String code) {
        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family: Arial, sans-serif; background:#f6f6f6; padding:20px;">
              <div style="max-width:520px; margin:auto; background:#fff; border-radius:12px; padding:40px 32px;">
                <h2 style="color:#1d1d1f; margin-top:0; text-align:center;">Đặt lại mật khẩu</h2>
                <p style="font-size:15px; color:#555; text-align:center; margin-bottom:32px;">
                  Chào %s, mã đặt lại mật khẩu của bạn là:
                </p>
                <div style="text-align:center; margin:32px 0;">
                  <div style="display:inline-block; padding:20px 40px; background:#fff3e0;
                              border-radius:12px; font-size:42px; font-weight:bold;
                              letter-spacing:12px; color:#ff6b35; font-family:'Courier New', monospace;">
                    %s
                  </div>
                </div>
                <p style="font-size:13px; color:#999; text-align:center;">
                  Mã có hiệu lực trong 15 phút.<br>
                  Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này và đổi mật khẩu ngay để bảo mật.
                </p>
              </div>
            </body>
            </html>
            """.formatted(HtmlUtils.htmlEscape(username), code);
    }

    private String buildCodeHtml(String username, String code) {
        return """
                <!DOCTYPE html>
                <html>
                <head><meta charset="UTF-8"></head>
                <body style="font-family: Arial, sans-serif; background:#f6f6f6; padding:20px;">
                  <div style="max-width:520px; margin:auto; background:#fff; border-radius:12px; padding:40px 32px; box-shadow:0 2px 8px rgba(0,0,0,0.05);">
                    <h2 style="color:#1d1d1f; margin-top:0; text-align:center;">Chào %s 👋</h2>
                    <p style="font-size:15px; color:#555; text-align:center; margin-bottom:32px;">
                      Mã xác thực tài khoản <strong>Bookish</strong> của bạn là:
                    </p>
                    <div style="text-align:center; margin:32px 0;">
                      <div style="display:inline-block; padding:20px 40px; background:#f5f5f7;
                                  border-radius:12px; font-size:42px; font-weight:bold;
                                  letter-spacing:12px; color:#0071e3; font-family:'Courier New', monospace;">
                        %s
                      </div>
                    </div>
                    <p style="font-size:13px; color:#999; text-align:center;">
                      Mã có hiệu lực trong 10 phút.<br>
                      Nếu bạn không đăng ký tài khoản tại Bookish, hãy bỏ qua email này.
                    </p>
                  </div>
                </body>
                </html>
                """.formatted(HtmlUtils.htmlEscape(username), code);
    }
}
