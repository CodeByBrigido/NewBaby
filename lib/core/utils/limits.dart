/// Limites de tamanho dos textos que o aplicativo grava.
///
/// Estes números vivem em dois lugares: aqui, para a interface impedir que
/// alguém escreva além do permitido, e em `firebase/firestore.rules`, para o
/// servidor recusar quem não passou pela interface.
///
/// A duplicação é proposital — a regra do servidor é a que vale, e ela não
/// pode depender de o cliente se comportar. Mas se um lado mudar sem o outro,
/// a pessoa escreve à vontade e só descobre o limite na hora de salvar, com
/// uma mensagem genérica. `test/limits_test.dart` compara os dois arquivos
/// para que isso não passe despercebido.
abstract final class Limits {
  static const int babyName = 120;
  static const int hospital = 200;

  /// Título de carta, marco e nome de documento.
  static const int title = 200;

  /// Corpo da carta. Folgado de propósito: é para escrever de verdade.
  static const int description = 20000;
}
