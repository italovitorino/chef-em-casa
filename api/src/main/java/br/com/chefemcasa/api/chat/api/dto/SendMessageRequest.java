package br.com.chefemcasa.api.chat.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SendMessageRequest(
        @NotBlank(message = "Conteúdo não pode estar vazio")
        @Size(max = 2000, message = "Mensagem muito longa")
        String content
) {}
