/// The keys the chain's steps leave notes for each other under, on one
/// request's own side data.
///
/// The notes ride the REQUEST, not a field on an interceptor: a field would be
/// shared by every request in flight, and two requests renewing at once would
/// read each other's note.
abstract final class RequestExtras {
  /// The token set a renewal just obtained, handed to the step that attaches
  /// it so this request rides the fresh value rather than the held one the
  /// auth bloc has not saved yet.
  ///
  /// Both renewing steps write it: the proactive one before the request goes
  /// out, the reactive one before it sends a refused request again. Its
  /// presence also tells the proactive step this request is already carrying a
  /// fresh set, so it renews nothing.
  static const String renewedTokens = 'authRenewedTokens';

  /// Marks a request that has already been retried once after a renewal, so a
  /// second refusal ends the request instead of looping, and so the proactive
  /// step leaves the retry alone.
  static const String retriedAfterRenewal = 'authRetriedAfterRenewal';
}
