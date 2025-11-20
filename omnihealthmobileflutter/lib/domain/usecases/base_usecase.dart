/// Generic UseCase interface
/// Input [Params], Output [Result]
abstract class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

/// For usecases without parameters (e.g. logout)
class NoParams {}
