import nodemailer from "nodemailer";
import { logError, logAudit } from "./LoggerUtil";
import { StatusLogEnum } from "../common/constants/AppConstants";

/**
 * Email Service - Xử lý việc gửi email cho ứng dụng
 *
 * Environment Variables cần thiết:
 * - SMTP_HOST: SMTP server host (vd: smtp.gmail.com, smtp.resend.com)
 * - SMTP_PORT: SMTP port (vd: 587, 465)
 * - SMTP_USER: Email username/address (hoặc "resend" nếu dùng Resend)
 * - SMTP_PASS: Email password, App Password, hoặc API key
 * - SMTP_FROM_NAME: Tên người gửi (vd: OmniMer Health)
 * - SMTP_FROM_EMAIL: Email người gửi
 * - CLIENT_URL: URL của frontend app (dùng cho deep linking)
 * - BACKEND_URL: URL của backend server
 * - EMAIL_DEV_MODE: Set "true" để skip gửi email thực (dev only)
 */

// Cấu hình transporter
const createTransporter = () => {
  // Resend SMTP config
  if (process.env.SMTP_HOST === "smtp.resend.com") {
    return nodemailer.createTransport({
      host: "smtp.resend.com",
      port: 465,
      secure: true,
      auth: {
        user: "resend",
        pass: process.env.SMTP_PASS, // Resend API Key
      },
    });
  }

  // Gmail / Other SMTP config
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || "smtp.gmail.com",
    port: parseInt(process.env.SMTP_PORT || "587"),
    secure: process.env.SMTP_SECURE === "true", // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
    connectionTimeout: 10000, // 10 seconds
    greetingTimeout: 10000,
    socketTimeout: 10000,
  });
};

// Email templates
const emailTemplates = {
  verification: (userName: string, verificationLink: string) => ({
    subject: "🔐 Xác thực email của bạn - OmniMer Health",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Xác thực Email</title>
      </head>
      <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
        <table role="presentation" style="width: 100%; border-collapse: collapse;">
          <tr>
            <td align="center" style="padding: 40px 0;">
              <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                <!-- Header -->
                <tr>
                  <td style="padding: 40px 40px 20px; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 16px 16px 0 0;">
                    <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700;">
                      🏃 OmniMer Health
                    </h1>
                    <p style="margin: 10px 0 0; color: rgba(255,255,255,0.9); font-size: 14px;">
                      Your Personal Health Companion
                    </p>
                  </td>
                </tr>
                
                <!-- Content -->
                <tr>
                  <td style="padding: 40px;">
                    <h2 style="margin: 0 0 20px; color: #1a1a2e; font-size: 24px; font-weight: 600;">
                      Xin chào ${userName}! 👋
                    </h2>
                    <p style="margin: 0 0 20px; color: #4a5568; font-size: 16px; line-height: 1.6;">
                      Cảm ơn bạn đã đăng ký tài khoản OmniMer Health. Để hoàn tất quá trình đăng ký và bắt đầu hành trình sức khỏe của bạn, vui lòng xác thực địa chỉ email.
                    </p>
                    
                    <!-- Button -->
                    <table role="presentation" style="width: 100%; border-collapse: collapse;">
                      <tr>
                        <td align="center" style="padding: 30px 0;">
                          <a href="${verificationLink}" style="display: inline-block; padding: 16px 48px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; text-decoration: none; font-size: 16px; font-weight: 600; border-radius: 50px; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);">
                            ✅ Xác thực Email
                          </a>
                        </td>
                      </tr>
                    </table>
                    
                    <p style="margin: 0 0 20px; color: #718096; font-size: 14px; line-height: 1.6;">
                      Hoặc copy và paste đường link sau vào trình duyệt:
                    </p>
                    <p style="margin: 0 0 30px; padding: 15px; background-color: #f7fafc; border-radius: 8px; word-break: break-all; color: #667eea; font-size: 14px;">
                      ${verificationLink}
                    </p>
                    
                    <div style="padding: 20px; background-color: #fef3c7; border-radius: 8px; border-left: 4px solid #f59e0b;">
                      <p style="margin: 0; color: #92400e; font-size: 14px;">
                        ⏰ <strong>Lưu ý:</strong> Link xác thực này sẽ hết hạn sau 24 giờ.
                      </p>
                    </div>
                  </td>
                </tr>
                
                <!-- Footer -->
                <tr>
                  <td style="padding: 30px 40px; background-color: #f7fafc; border-radius: 0 0 16px 16px; text-align: center;">
                    <p style="margin: 0 0 10px; color: #718096; font-size: 14px;">
                      Nếu bạn không yêu cầu email này, vui lòng bỏ qua.
                    </p>
                    <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                      © 2025 OmniMer Health. All rights reserved.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    `,
    text: `
      Xin chào ${userName}!
      
      Cảm ơn bạn đã đăng ký tài khoản OmniMer Health.
      
      Để xác thực email của bạn, vui lòng truy cập link sau:
      ${verificationLink}
      
      Link này sẽ hết hạn sau 24 giờ.
      
      Nếu bạn không yêu cầu email này, vui lòng bỏ qua.
      
      © 2025 OmniMer Health
    `,
  }),

  passwordReset: (userName: string, resetCode: string) => ({
    subject: "🔑 Mã khôi phục mật khẩu - OmniMer Health",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Khôi phục mật khẩu</title>
      </head>
      <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
        <table role="presentation" style="width: 100%; border-collapse: collapse;">
          <tr>
            <td align="center" style="padding: 40px 0;">
              <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                <!-- Header -->
                <tr>
                  <td style="padding: 40px 40px 20px; text-align: center; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); border-radius: 16px 16px 0 0;">
                    <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700;">
                      🔑 OmniMer Health
                    </h1>
                    <p style="margin: 10px 0 0; color: rgba(255,255,255,0.9); font-size: 14px;">
                      Khôi phục mật khẩu
                    </p>
                  </td>
                </tr>
                
                <!-- Content -->
                <tr>
                  <td style="padding: 40px;">
                    <h2 style="margin: 0 0 20px; color: #1a1a2e; font-size: 24px; font-weight: 600;">
                      Xin chào ${userName}! 👋
                    </h2>
                    <p style="margin: 0 0 20px; color: #4a5568; font-size: 16px; line-height: 1.6;">
                      Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản của bạn. Sử dụng mã bên dưới để đặt lại mật khẩu.
                    </p>
                    
                    <!-- Code Box -->
                    <table role="presentation" style="width: 100%; border-collapse: collapse;">
                      <tr>
                        <td align="center" style="padding: 30px 0;">
                          <div style="background: linear-gradient(135deg, #f4f7fa 0%, #e2e8f0 100%); border-radius: 12px; padding: 25px 40px; display: inline-block;">
                            <p style="margin: 0 0 10px; color: #718096; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">
                              Mã khôi phục của bạn
                            </p>
                            <div style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #1a1a2e; font-family: 'Courier New', monospace;">
                              ${resetCode}
                            </div>
                          </div>
                        </td>
                      </tr>
                    </table>
                    
                    <div style="padding: 20px; background-color: #fef3c7; border-radius: 8px; border-left: 4px solid #f59e0b; margin-bottom: 20px;">
                      <p style="margin: 0; color: #92400e; font-size: 14px;">
                        ⏰ <strong>Lưu ý:</strong> Mã này sẽ hết hạn sau <strong>10 phút</strong>.
                      </p>
                    </div>
                    
                    <div style="padding: 20px; background-color: #fef2f2; border-radius: 8px; border-left: 4px solid #ef4444;">
                      <p style="margin: 0; color: #991b1b; font-size: 14px;">
                        🔒 <strong>Bảo mật:</strong> Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng bỏ qua email này và đảm bảo tài khoản của bạn vẫn an toàn.
                      </p>
                    </div>
                  </td>
                </tr>
                
                <!-- Footer -->
                <tr>
                  <td style="padding: 30px 40px; background-color: #f7fafc; border-radius: 0 0 16px 16px; text-align: center;">
                    <p style="margin: 0 0 10px; color: #718096; font-size: 14px;">
                      Không chia sẻ mã này với bất kỳ ai.
                    </p>
                    <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                      © 2025 OmniMer Health. All rights reserved.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    `,
    text: `
      Xin chào ${userName}!
      
      Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản của bạn.
      
      Mã khôi phục của bạn là: ${resetCode}
      
      Mã này sẽ hết hạn sau 10 phút.
      
      Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng bỏ qua email này.
      
      © 2025 OmniMer Health
    `,
  }),

  passwordResetSuccess: (userName: string) => ({
    subject: "✅ Mật khẩu đã được đặt lại thành công - OmniMer Health",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
        <table role="presentation" style="width: 100%; border-collapse: collapse;">
          <tr>
            <td align="center" style="padding: 40px 0;">
              <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                <tr>
                  <td style="padding: 40px; text-align: center;">
                    <div style="width: 80px; height: 80px; margin: 0 auto 20px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                      <span style="font-size: 40px; line-height: 80px;">🔐</span>
                    </div>
                    <h1 style="margin: 0 0 20px; color: #1a1a2e; font-size: 28px;">
                      Mật khẩu đã được đặt lại!
                    </h1>
                    <p style="margin: 0 0 30px; color: #4a5568; font-size: 16px; line-height: 1.6;">
                      Xin chào ${userName}, mật khẩu của bạn đã được đặt lại thành công. Bạn có thể đăng nhập bằng mật khẩu mới.
                    </p>
                    <div style="padding: 20px; background-color: #fef2f2; border-radius: 8px; border-left: 4px solid #ef4444; text-align: left;">
                      <p style="margin: 0; color: #991b1b; font-size: 14px;">
                        🔒 <strong>Bảo mật:</strong> Nếu bạn không thực hiện thay đổi này, vui lòng liên hệ với chúng tôi ngay lập tức.
                      </p>
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    `,
    text: `Xin chào ${userName}! Mật khẩu của bạn đã được đặt lại thành công. Nếu bạn không thực hiện thay đổi này, vui lòng liên hệ với chúng tôi ngay.`,
  }),

  verificationSuccess: (userName: string) => ({
    subject: "✅ Email đã được xác thực thành công - OmniMer Health",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
        <table role="presentation" style="width: 100%; border-collapse: collapse;">
          <tr>
            <td align="center" style="padding: 40px 0;">
              <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                <tr>
                  <td style="padding: 40px; text-align: center;">
                    <div style="width: 80px; height: 80px; margin: 0 auto 20px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                      <span style="font-size: 40px; line-height: 80px;">✓</span>
                    </div>
                    <h1 style="margin: 0 0 20px; color: #1a1a2e; font-size: 28px;">
                      Xác thực thành công!
                    </h1>
                    <p style="margin: 0 0 30px; color: #4a5568; font-size: 16px; line-height: 1.6;">
                      Chào ${userName}, email của bạn đã được xác thực thành công. Bây giờ bạn có thể sử dụng đầy đủ các tính năng của OmniMer Health.
                    </p>
                    <a href="${process.env.CLIENT_URL || "omnihealthapp://verified"}" style="display: inline-block; padding: 16px 48px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; text-decoration: none; font-size: 16px; font-weight: 600; border-radius: 50px;">
                      Mở Ứng dụng
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    `,
    text: `Xin chào ${userName}! Email của bạn đã được xác thực thành công. Bạn có thể sử dụng đầy đủ các tính năng của OmniMer Health.`,
  }),
};

export interface SendEmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export const EmailService = {
  /**
   * Gửi email generic
   */
  async sendEmail(options: SendEmailOptions): Promise<boolean> {
    try {
      // DEV MODE: Skip sending real email, just log
      if (process.env.EMAIL_DEV_MODE === "true") {
        console.log("\n📧 ═══════════════════════════════════════════════════");
        console.log("📧 EMAIL DEV MODE - Not sending real email");
        console.log("📧 ═══════════════════════════════════════════════════");
        console.log(`📧 To: ${options.to}`);
        console.log(`📧 Subject: ${options.subject}`);
        console.log("📧 ═══════════════════════════════════════════════════\n");

        await logAudit({
          action: "sendEmail",
          message: `[DEV MODE] Email logged for ${options.to}`,
          status: StatusLogEnum.Success,
          metadata: { subject: options.subject, devMode: true },
        });

        return true;
      }

      const transporter = createTransporter();

      const fromName = process.env.SMTP_FROM_NAME || "OmniMer Health";
      const fromEmail = process.env.SMTP_FROM_EMAIL || process.env.SMTP_USER;

      await transporter.sendMail({
        from: `"${fromName}" <${fromEmail}>`,
        to: options.to,
        subject: options.subject,
        html: options.html,
        text: options.text,
      });

      await logAudit({
        action: "sendEmail",
        message: `Email sent successfully to ${options.to}`,
        status: StatusLogEnum.Success,
        metadata: { subject: options.subject },
      });

      return true;
    } catch (error: any) {
      await logError({
        action: "sendEmail",
        message: `Failed to send email to ${options.to}`,
        errorMessage: error.message || error,
      });
      throw error;
    }
  },

  /**
   * Gửi email xác thực
   */
  async sendVerificationEmail(
    email: string,
    userName: string,
    verificationToken: string
  ): Promise<boolean> {
    const backendUrl = process.env.BACKEND_URL || "http://localhost:8000";
    const verificationLink = `${backendUrl}/api/v1/verification/verify-email?token=${verificationToken}`;

    const template = emailTemplates.verification(userName, verificationLink);

    return this.sendEmail({
      to: email,
      subject: template.subject,
      html: template.html,
      text: template.text,
    });
  },

  /**
   * Gửi email thông báo xác thực thành công
   */
  async sendVerificationSuccessEmail(
    email: string,
    userName: string
  ): Promise<boolean> {
    const template = emailTemplates.verificationSuccess(userName);

    return this.sendEmail({
      to: email,
      subject: template.subject,
      html: template.html,
      text: template.text,
    });
  },

  /**
   * Gửi email mã khôi phục mật khẩu
   */
  async sendPasswordResetEmail(
    email: string,
    userName: string,
    resetCode: string
  ): Promise<boolean> {
    const template = emailTemplates.passwordReset(userName, resetCode);

    return this.sendEmail({
      to: email,
      subject: template.subject,
      html: template.html,
      text: template.text,
    });
  },

  /**
   * Gửi email thông báo đặt lại mật khẩu thành công
   */
  async sendPasswordResetSuccessEmail(
    email: string,
    userName: string
  ): Promise<boolean> {
    const template = emailTemplates.passwordResetSuccess(userName);

    return this.sendEmail({
      to: email,
      subject: template.subject,
      html: template.html,
      text: template.text,
    });
  },
};

