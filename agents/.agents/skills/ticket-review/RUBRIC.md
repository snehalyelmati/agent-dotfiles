# Scoring reviews of one ticket

Score each review 0-2 per line. Higher total wins; ties go to the review
with more defects later confirmed.

1. Defects found that a reproducer or second reader later confirmed.
2. Citation accuracy: cited lines reopen to the claimed code.
3. Snapshot stated: commit, time and dependency state as fetched.
4. Scope changes surfaced for approval rather than silently applied.
5. Rebuild prevented: already-shipped behavior named with references.
