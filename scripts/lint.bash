#!/usr/bin/env bash

# lint this repo
shellcheck --shell=bash --external-sources \
	bin/* \
	lib/* \
	scripts/*

shfmt --language-dialect bash --diff \
	bin/* \
	lib/* \
	scripts/*
