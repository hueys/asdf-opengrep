#!/usr/bin/env bash

# lint this repo
shellcheck --shell=bash --external-sources \
	scripts/*

shfmt --language-dialect bash --diff \
	scripts/*
