# Changelog

## 0.0.6

- Fixed `Token#id` output on Ruby 3.4+: Ruby 3.4 changed `Hash#inspect`'s
  format, which had silently changed the `id` column's output (and the
  sort order it ties into) on those newer versions. `id` now matches
  what Ruby 2.7-3.3 have always produced.
