#!/bin/bash

#
# TODO rewrite this in a generalized fashion
#

function die() {
	echo "$(basename "$0"): $*" >&2
	exit 1
}

function do_clean() {
	rm -rf target
}

function do_configure() {
	if [[ ${OSTYPE} == "msys" || ${OSTYPE} == "mingw"* || ${OSTYPE} == "cygwin" ]]; then
		die "Unsupported operating system"
	fi

	if [[ -z ${NEANES_BIN} ]]; then
		# shellcheck disable=SC2086
		NEANES_BIN=$(echo $HOME/src/neanes/neanes/dist/Neanes-*.AppImage) || die "failed to expand glob"
	fi

	if [[ ! -x ${NEANES_BIN} ]]; then
		die "${NEANES_BIN} is not executable"
	fi
}

function do_compile() {
	find . -type f -name '*.byzx' -print0 | xargs -0 "${NEANES_BIN}" --silent-pdf
	while IFS= read -r -d '' FILE; do
		TARGET_DIR="target/pdf/$(dirname "${FILE}")"
		mkdir -p "${TARGET_DIR}"
		mv "${FILE}" "${TARGET_DIR}"
	done < <(find . -type f -name '*.pdf' -print0)
}

function do_dist() {
	rm -rf target/site
	mkdir -p target/site/tmp
	rsync -av target/pdf/ target/site/tmp
	rsync -av site/ target/site
}

function main() {
	for TARGET in "$@"; do
		if declare -f "do_${TARGET}" >/dev/null; then
			"do_${TARGET}"
		else
			die "Unknown target: ${TARGET}"
		fi
	done
}

main "$@"
