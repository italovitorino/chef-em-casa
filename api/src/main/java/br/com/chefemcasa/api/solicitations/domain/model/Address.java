package br.com.chefemcasa.api.solicitations.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

@Embeddable
public record Address(
        String street,
        String number,
        String city,
        String state,

        @Column(name = "zip_code")
        String zipCode
) {}
