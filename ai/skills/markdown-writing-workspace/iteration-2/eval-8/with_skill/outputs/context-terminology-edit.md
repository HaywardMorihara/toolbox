# Definition Edit Result — Eval-8

## Before

**Gateway**: Component responsible for routing requests. Handles primary use cases.

## After

**Gateway**: Component responsible for routing requests. Handles both primary (synchronous) and secondary (asynchronous) use cases.

---

## Explanation

The edited definition now encompasses both execution paths:
- **Primary**: Synchronous request handling (original scope)
- **Secondary/Async**: Asynchronous job execution paths (new clarification)

This clarification makes it explicit that the Gateway definition applies across all execution modes, not just primary paths.
