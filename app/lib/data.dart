import 'package:flutter/material.dart';

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
