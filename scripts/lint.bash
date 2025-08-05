#!/usr/bin/env bash

# lint this repo
shellcheck --shell=bash --external-sources \
	bin/* \
	lib/* \
	scripts/format.bash

# lint test script separately without external-sources check
shellcheck --shell=bash \
	scripts/test.bash

shfmt --language-dialect bash --diff \
	bin/* \
	lib/* \
	scripts/*
