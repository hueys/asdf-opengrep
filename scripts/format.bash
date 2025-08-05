#!/usr/bin/env bash

# format this repo
shfmt --language-dialect bash --write \
	bin/* \
	lib/* \
	scripts/*
