/// Se a criança é menino ou menina.
///
/// Existe por um motivo só: o aplicativo é em português, e português tem
/// gênero. Sem isso, metade das famílias veria o app falando do filho delas
/// na forma errada.
enum BabyGender {
  girl('menina', 'Menina'),
  boy('menino', 'Menino');

  const BabyGender(this.id, this.label);

  /// Valor gravado no Firestore.
  final String id;

  /// Como aparece no seletor do cadastro.
  final String label;

  bool get isGirl => this == BabyGender.girl;

  /// `null` para cadastros antigos ou incompletos — quem lê deve cair na
  /// forma neutra, nunca adivinhar.
  static BabyGender? fromId(String? id) {
    for (final BabyGender gender in values) {
      if (gender.id == id) return gender;
    }
    return null;
  }
}
