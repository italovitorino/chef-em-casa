package br.com.chefemcasa.api.shared.api;

import br.com.chefemcasa.api.identity.domain.exception.EmailAlreadyRegisteredException;
import br.com.chefemcasa.api.identity.domain.exception.InvalidCredentialsException;
import br.com.chefemcasa.api.identity.domain.exception.UserNotFoundException;
import br.com.chefemcasa.api.solicitations.domain.exception.InvalidTransitionException;
import br.com.chefemcasa.api.solicitations.domain.exception.SolicitationNotFoundException;
import br.com.chefemcasa.api.solicitations.domain.exception.UnauthorizedActorException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(EmailAlreadyRegisteredException.class)
    public ResponseEntity<ProblemDetail> handleEmailAlreadyRegistered(EmailAlreadyRegisteredException ex) {
        var pd = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, ex.getMessage());
        pd.setTitle("Conflito");
        return ResponseEntity.status(HttpStatus.CONFLICT).body(pd);
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<ProblemDetail> handleInvalidCredentials() {
        var pd = ProblemDetail.forStatusAndDetail(HttpStatus.UNAUTHORIZED, "Credenciais inválidas");
        pd.setTitle("Não autorizado");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(pd);
    }

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ProblemDetail> handleUserNotFound(UserNotFoundException ex) {
        var pd = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        pd.setTitle("Não encontrado");
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(pd);
    }

    @ExceptionHandler(SolicitationNotFoundException.class)
    public ResponseEntity<ProblemDetail> handleSolicitationNotFound(SolicitationNotFoundException ex) {
        var pd = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        pd.setTitle("Não encontrado");
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(pd);
    }

    @ExceptionHandler(InvalidTransitionException.class)
    public ResponseEntity<ProblemDetail> handleInvalidTransition(InvalidTransitionException ex) {
        var pd = ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_ENTITY, ex.getMessage());
        pd.setTitle("Transição inválida");
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(pd);
    }

    @ExceptionHandler(UnauthorizedActorException.class)
    public ResponseEntity<ProblemDetail> handleUnauthorizedActor(UnauthorizedActorException ex) {
        var pd = ProblemDetail.forStatusAndDetail(HttpStatus.FORBIDDEN, ex.getMessage());
        pd.setTitle("Acesso negado");
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(pd);
    }
}
