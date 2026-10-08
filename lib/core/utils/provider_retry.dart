/// Riverpod retries a provider that throws, with growing pauses, so a screen
/// can sit on its loading skeleton for a long time before it shows an error.
/// For data that comes from the network the person should see the friendly
/// error (with its "Try again" button) straight away, so those providers use
/// this to opt out. Pass it as `@Riverpod(retry: neverRetry)`.
Duration? neverRetry(int retryCount, Object error) => null;
