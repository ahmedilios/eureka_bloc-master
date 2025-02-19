import '../../models/model.dart';

/// Representa um token para autenticação.
///
/// Você deve estender desta classe e inserir as propriedades referentes ao
/// token que sua API utilizar. Cada mixin de autenticação pode manipular este
/// modelo de forma diferente dentro da [EurekaApi].
abstract class Token implements ShortModel, DetailModel {
  Map<String, dynamic> toJson();
}
