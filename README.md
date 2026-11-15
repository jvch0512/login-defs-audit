# login-defs-audit

login-defs-audit reads the two files that set a Linux host's password and account policy, `/etc/login.defs` and `pwquality.conf` (with its `pwquality.conf.d` drop-ins), and checks them against the usual benchmark values: password lifetime and warning, the hashing method for new passwords, the default `umask`, login retries, minimum length, character classes, dictionary checks and whether the rules are enforced at all.

**Live demo:** https://jvch0512.github.io/login-defs-audit/ (Synthetic policy files.)

GNU Guile 3 (Scheme), standard modules only. The demo page is rendered from the tool's `--tsv` output by `scripts/site.py` (Python 3, only needed to regenerate the page).

## Use

```bash
bin/login-defs-audit examples
bin/login-defs-audit /etc/login.defs --tsv
bin/login-defs-audit /etc --fail-on high       # exit 1 on any high finding
```

Pass a file or a directory. Files named `login.defs` and `pwquality.conf`, and `.conf` files inside a `pwquality.conf.d` folder, are read. Directories are searched recursively.

| Rule | Severity | What it catches |
|---|---|---|
| LGN001 | medium | `PASS_MAX_DAYS` missing or above 365 |
| LGN002 | low | `PASS_MIN_DAYS` missing or 0: a user can change a password back at once |
| LGN003 | low | `PASS_WARN_AGE` missing or under 7 |
| LGN004 | high or low | `ENCRYPT_METHOD` MD5 or DES (high); SHA256 or not set (low) |
| LGN005 | medium or low | `UMASK` that leaves new files readable by others (medium); not set (low) |
| LGN006 | low | `LOGIN_RETRIES` missing or above 5 |
| LGN007 | medium | `minlen` missing or under 12 |
| LGN008 | medium | no complexity rule: `minclass` under 3 and no negative `dcredit`, `ucredit`, `lcredit` or `ocredit` |
| LGN009 | medium | `dictcheck = 0` or `usercheck = 0` |
| LGN010 | medium | `enforcing = 0`: weak passwords only produce a warning |
| LGN000 | info | a line that is not a setting, ignored |

See [examples](examples) and [docs/sample-output.txt](docs/sample-output.txt).

## Limits

- Only these two files are read. PAM stacks (`/etc/pam.d`), `faillock` and `chage` data per user are separate reviews.
- Values are compared against common benchmark numbers, not against your own policy. Edit the thresholds in `src/lda/audit.scm` if yours differ.
- `PASS_MAX_DAYS` and friends only affect accounts created afterwards. Existing accounts keep what `chage` set.
- On distributions that use `yescrypt` the setting is `YESCRYPT_COST_FACTOR`; a missing `ENCRYPT_METHOD` is reported as low for that reason.

## Where it fits

Linux hardening and CIS benchmark reviews: a fast check of password and account policy files.

## Tests

```bash
make test    # 69 checks, incl. 3000-case fuzzing and CLI exit codes
```

MIT.
