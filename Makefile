# directory - not useful to run it in the 'common' directory

# adjust for github usage
# /$home=$(shell git rev-parse --show-toplevel)
REPO_TOP=$(shell git rev-parse --show-toplevel 2>/dev/null || echo ${HOME} )
echo "Using REPO_TOP=${REPO_TOP}"
include ${REPO_TOP}/common/mk/core.mk

