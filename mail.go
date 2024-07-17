package mail

import (
	"gopkg.in/gomail.v2"
	"fmt"
)

// MailConfig holds the configuration details for sending an email
type MailConfig struct {
	From     string
	Password string // Application-specific password recommended
	SMTPHost string
	SMTPPort int
}

// SendEmail sends an email with the given details
func (mc *MailConfig) SendEmail(to, subject, body string) error {
	d := gomail.NewDialer(mc.SMTPHost, mc.SMTPPort, mc.From, mc.Password)

	m := gomail.NewMessage()
	m.SetHeader("From", mc.From)
	m.SetHeader("To", to)
	m.SetHeader("Subject", subject)
	m.SetBody("text/plain", body)

	if err := d.DialAndSend(m); err != nil {
		return fmt.Errorf("failed to send email: %w", err)
	}

	return nil
}


package main

import (
	"fmt"
	"yourproject/mail" // Adjust the import path according to your project structure
)

func main() {
	// Initialize mail configuration directly
	mailConfig := mail.MailConfig{
		From:     "your-email@gmail.com",
		Password: "your-gmail-password",
		SMTPHost: "smtp.gmail.com",
		SMTPPort: 587,
	}

	to := "recipient@example.com"
	subject := "Subject: Testing Email from Go"
	body := "This is a test email from Go using Gmail SMTP server."

	// Send email using the SendEmail method
	err := mailConfig.SendEmail(to, subject, body)
	if err != nil {
		fmt.Println("Failed to send email:", err)
		return
	}

	fmt.Println("Email sent successfully!")
}
