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

// NewMailConfig is a constructor function to create a new MailConfig
func NewMailConfig(from, password, smtpHost string, smtpPort int) *MailConfig {
	return &MailConfig{
		From:     from,
		Password: password,
		SMTPHost: smtpHost,
		SMTPPort: smtpPort,
	}
}

// SendEmail sends an email with the given details
func (mc *MailConfig) SendEmail(to, subject, body string) error {
	d := gomail.NewDialer(mc.SMTPHost, mc.SMTPPort, mc.From, mc.Password)

	m := gomail.NewMessage()
	m.SetHeader("From", mc.From)
	m.SetHeader("To", to)
	m.SetHeader("Subject", subject)
	m.SetBody("text/plain", body)

	return d.DialAndSend(m)
}
