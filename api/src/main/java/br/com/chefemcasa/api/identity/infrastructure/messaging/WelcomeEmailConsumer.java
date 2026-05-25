package br.com.chefemcasa.api.identity.infrastructure.messaging;

import br.com.chefemcasa.api.identity.domain.event.UserRegistered;
import br.com.chefemcasa.api.shared.infrastructure.messaging.RabbitMQConfig;
import jakarta.mail.MessagingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

@Component
public class WelcomeEmailConsumer {

    private static final Logger log = LoggerFactory.getLogger(WelcomeEmailConsumer.class);

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String from;

    public WelcomeEmailConsumer(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    @RabbitListener(queues = RabbitMQConfig.WELCOME_EMAIL_QUEUE)
    public void handleUserRegistered(UserRegistered event) {
        log.info("[WELCOME-EMAIL] Evento recebido para userId={}, email={}", event.userId(), event.email());
        try {
            var message = mailSender.createMimeMessage();
            var helper = new MimeMessageHelper(message, "UTF-8");
            helper.setFrom(from);
            helper.setTo(event.email());
            helper.setSubject("Bem-vindo ao Chef em Casa!");
            helper.setText(buildBody(), true);
            mailSender.send(message);
            log.info("[WELCOME-EMAIL] E-mail enviado com sucesso para {}", event.email());
        } catch (MessagingException | MailException e) {
            log.error("[WELCOME-EMAIL] Falha ao enviar e-mail para {}: {}", event.email(), e.getMessage());
        }
    }

    private String buildBody() {
        return """
                <html>
                <body style="font-family: Arial, sans-serif; color: #333;">
                    <h2>Bem-vindo ao Chef em Casa!</h2>
                    <p>Sua conta foi criada com sucesso.</p>
                    <p>Agora você pode explorar chefs disponíveis e solicitar experiências gastronômicas exclusivas.</p>
                    <br>
                    <p>Equipe Chef em Casa</p>
                </body>
                </html>
                """;
    }
}
