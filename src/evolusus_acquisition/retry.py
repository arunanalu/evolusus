from dataclasses import dataclass
import random

@dataclass(frozen=True)
class RetryDecision:
    retryable: bool
    delay_seconds: float | None
    reason: str

def classify(status: int | None, attempt: int, policy: dict, retry_after: float | None = None) -> RetryDecision:
    if status in (400, 401, 403, 404):
        return RetryDecision(False, None, f"http_{status}")
    retryable = status is None or status in (408, 425, 429, 503) or (status is not None and 500 <= status <= 599)
    if not retryable or attempt >= policy["max_attempts"]:
        return RetryDecision(False, None, "attempts_exhausted" if retryable else f"http_{status}")
    base = min(policy["max_delay_seconds"], policy["base_delay_seconds"] * (2 ** (attempt - 1)))
    delay = retry_after if retry_after is not None and retry_after >= 0 else base
    jitter = policy.get("jitter_ratio", 0) * delay
    return RetryDecision(True, max(0.0, delay + random.uniform(-jitter, jitter)), "retryable")
