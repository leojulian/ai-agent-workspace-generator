#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	printf '[failed] source ./set-env.sh in the current Bash session\n' >&2
	exit 2
fi

aawt_load_env() {
	local AAWT_INTERNAL_ROOT AAWT_INTERNAL_FILE AAWT_INTERNAL_LINE
	local AAWT_INTERNAL_KEY AAWT_INTERNAL_VALUE
	local -i AAWT_INTERNAL_LINE_NO=0 AAWT_INTERNAL_INDEX=0
	local -a AAWT_INTERNAL_KEYS=() AAWT_INTERNAL_VALUES=()

	if (($# != 0)); then
		printf '[failed] set-env.sh does not accept arguments\n' >&2
		return 2
	fi

	AAWT_INTERNAL_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
	AAWT_INTERNAL_FILE="$AAWT_INTERNAL_ROOT/.env"
	if [[ ! -f "$AAWT_INTERNAL_FILE" ]]; then
		printf '[failed] .env not found; run set-workspace.sh first\n' >&2
		return 1
	fi

	while IFS= read -r AAWT_INTERNAL_LINE || [[ -n $AAWT_INTERNAL_LINE ]]; do
		((AAWT_INTERNAL_LINE_NO += 1))
		AAWT_INTERNAL_LINE=${AAWT_INTERNAL_LINE%$'\r'}
		[[ -z $AAWT_INTERNAL_LINE ]] && continue
		[[ ${AAWT_INTERNAL_LINE:0:1} == '#' ]] && continue
		if [[ $AAWT_INTERNAL_LINE != *=* ]]; then
			printf '[failed] invalid dotenv syntax at line %d\n' "$AAWT_INTERNAL_LINE_NO" >&2
			return 2
		fi

		AAWT_INTERNAL_KEY=${AAWT_INTERNAL_LINE%%=*}
		AAWT_INTERNAL_VALUE=${AAWT_INTERNAL_LINE#*=}
		if [[ ! $AAWT_INTERNAL_KEY =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] ||
			[[ $AAWT_INTERNAL_KEY == AAWT_INTERNAL_* ]] ||
			[[ ! $AAWT_INTERNAL_VALUE =~ ^[A-Za-z0-9._~:/?@+,=-]*$ ]]; then
			printf '[failed] invalid dotenv syntax at line %d\n' "$AAWT_INTERNAL_LINE_NO" >&2
			return 2
		fi
		AAWT_INTERNAL_KEYS+=("$AAWT_INTERNAL_KEY")
		AAWT_INTERNAL_VALUES+=("$AAWT_INTERNAL_VALUE")
	done <"$AAWT_INTERNAL_FILE"

	for ((AAWT_INTERNAL_INDEX = 0; AAWT_INTERNAL_INDEX < ${#AAWT_INTERNAL_KEYS[@]}; AAWT_INTERNAL_INDEX += 1)); do
		AAWT_INTERNAL_KEY=${AAWT_INTERNAL_KEYS[AAWT_INTERNAL_INDEX]}
		printf -v "$AAWT_INTERNAL_KEY" '%s' "${AAWT_INTERNAL_VALUES[AAWT_INTERNAL_INDEX]}"
		export "${AAWT_INTERNAL_KEY?}"
	done
	printf '[loaded] %d environment variables\n' "${#AAWT_INTERNAL_KEYS[@]}"
	return 0
}

aawt_load_env "$@"
case $? in
0)
	unset -f aawt_load_env
	return 0
	;;
1)
	unset -f aawt_load_env
	return 1
	;;
*)
	unset -f aawt_load_env
	return 2
	;;
esac
