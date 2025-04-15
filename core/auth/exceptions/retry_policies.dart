
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffFactor;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffFactor = 2.0,
  });

  Duration getDelayForAttempt(int attempt) {
    if (attempt >= maxAttempts) return Duration.zero;
    return initialDelay * (backoffFactor * attempt);
  }
}

class AuthRetryPolicy extends RetryPolicy {
  const AuthRetryPolicy()
      : super(
          maxAttempts: 3,
          initialDelay: const Duration(seconds: 1),
          backoffFactor: 2.0,
        );
}
