enum PlaceCategory {
  historicalPlace('Historical Place'),
  museum('Museum'),
  market('Market'),
  entertainAttraction('Entertain Attraction'),
  hotel('Hotel'),
  restaurant('Restaurant');

  final String displayName;

  const PlaceCategory(this.displayName);
} // categories place

enum Province {
  banteayMeanchey('Banteay Meanchey'),
  battambang('Battambang'),
  kampongCham('Kampong Cham'),
  kampongChhnang('Kampong Chhnang'),
  kampongSpeu('Kampong Speu'),
  kampot('Kampot'),
  kandal('Kandal'),
  kohKong('Koh Kong'),
  kratie('Kratie'),
  mondulkiri('Mondulkiri'),
  preahVihear('Preah Vihear'),
  preyVeng('Prey Veng'),
  pursat('Pursat'),
  ratanakiri('Ratanakiri'),
  siemReap('Siem Reap'),
  sihanoukville('Sihanoukville'),
  stungTreng('Stung Treng'),
  svayRieng('Svay Rieng'),
  takeo('Takeo'),
  tboungKhmum('Tboung Khmum'),
  phnomPenh('Phnom Penh'),
  kep('Kep'),
  oddarMeanchey('Oddar Meanchey'),
  pailin('Pailin');

  final String displayName;

  const Province(this.displayName);
}