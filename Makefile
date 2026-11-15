test:
	guile --no-auto-compile -L src -s tests/tests.scm

sample:
	mkdir -p docs site
	bin/login-defs-audit examples 2>/dev/null > docs/sample-output.txt; true
	bin/login-defs-audit examples --tsv 2>/dev/null > docs/sample-output.tsv; true
	python3 scripts/site.py docs/sample-output.tsv site/index.html "login-defs-audit" "Audits /etc/login.defs and pwquality.conf: password ageing, hashing method, umask, length and complexity rules. Guile Scheme." "Synthetic policy files."
