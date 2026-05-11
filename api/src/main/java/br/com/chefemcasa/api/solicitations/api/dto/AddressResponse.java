package br.com.chefemcasa.api.solicitations.api.dto;

public record AddressResponse(
        String street,
        String number,
        String city,
        String state,
        String zipCode
) {}
