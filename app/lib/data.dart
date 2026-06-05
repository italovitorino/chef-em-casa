import 'package:flutter/material.dart';

class Chef {
  final int id;
  final String name;
  final String cuisine;
  final double rating;
  final int reviews;
  final int price;
  final String city;
  final int hue;
  final bool verified;
  final String signature;

  const Chef({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.city,
    required this.hue,
    required this.verified,
    required this.signature,
  });
}

class EventType {
  final String id;
  final String label;
  final IconData icon;
  final String desc;
  final String apiKey; // valor do enum no backend (ex: 'ROMANTIC_DINNER')

  const EventType({
    required this.id,
    required this.label,
    required this.icon,
    required this.desc,
    required this.apiKey,
  });
}

const List<Chef> kChefs = [
  Chef(
    id: 1,
    name: 'Lucas Ferreira',
    cuisine: 'Contemporânea Autoral',
    rating: 4.9,
    reviews: 128,
    price: 180,
    city: 'Pinheiros',
    hue: 18,
    verified: true,
    signature: 'Ravióli de cordeiro, jus de alecrim',
  ),
  Chef(
    id: 2,
    name: 'Marina Costa',
    cuisine: 'Italiana de Raiz',
    rating: 4.8,
    reviews: 96,
    price: 150,
    city: 'Vila Madalena',
    hue: 34,
    verified: true,
    signature: 'Risoto de funghi e trufa negra',
  ),
  Chef(
    id: 3,
    name: 'Tomás Andrade',
    cuisine: 'Francesa Clássica',
    rating: 5.0,
    reviews: 74,
    price: 240,
    city: 'Jardins',
    hue: 8,
    verified: true,
    signature: 'Magret de pato, redução de cassis',
  ),
  Chef(
    id: 4,
    name: 'Bianca Rocha',
    cuisine: 'Brasileira Contemporânea',
    rating: 4.7,
    reviews: 152,
    price: 130,
    city: 'Perdizes',
    hue: 42,
    verified: false,
    signature: 'Moqueca de banana-da-terra',
  ),
  Chef(
    id: 5,
    name: 'Rafael Nunes',
    cuisine: 'Japonesa & Nikkei',
    rating: 4.9,
    reviews: 110,
    price: 210,
    city: 'Itaim',
    hue: 200,
    verified: true,
    signature: 'Omakase de 12 tempos',
  ),
];

final List<EventType> kEventTypes = [
  EventType(id: 'romantico',   label: 'Jantar Romântico',        icon: Icons.wine_bar,              desc: 'Dois lugares, alta gastronomia',    apiKey: 'ROMANTIC_DINNER'),
  EventType(id: 'aniversario', label: 'Aniversário',              icon: Icons.cake,                  desc: 'Celebração com bolo e menu',        apiKey: 'BIRTHDAY'),
  EventType(id: 'confra',      label: 'Confraternização',          icon: Icons.people,                desc: 'Grupos, amigos e equipe',           apiKey: 'SOCIAL_GATHERING'),
  EventType(id: 'negocios',    label: 'Jantar de Negócios',        icon: Icons.work,                  desc: 'Clientes e parceiros',              apiKey: 'BUSINESS_DINNER'),
  EventType(id: 'casamento',   label: 'Casamento Intimista',       icon: Icons.diamond,               desc: 'Cerimônia para poucos',             apiKey: 'INTIMATE_WEDDING'),
  EventType(id: 'familiar',    label: 'Reunião Familiar',          icon: Icons.home,                  desc: 'Almoço ou jantar em casa',          apiKey: 'FAMILY_REUNION'),
  EventType(id: 'degustacao',  label: 'Degustação & Harmonização', icon: Icons.auto_awesome,          desc: 'Menu degustação com vinhos',        apiKey: 'WINE_TASTING'),
  EventType(id: 'brunch',      label: 'Brunch',                    icon: Icons.wb_sunny,              desc: 'Manhã lenta de fim de semana',      apiKey: 'BRUNCH'),
  EventType(id: 'churrasco',   label: 'Churrasco Premium',         icon: Icons.local_fire_department, desc: 'Cortes nobres na brasa',            apiKey: 'PREMIUM_BBQ'),
  EventType(id: 'outros',      label: 'Outros',                    icon: Icons.more_horiz,            desc: 'Outro tipo de evento',              apiKey: 'OTHER'),
];
