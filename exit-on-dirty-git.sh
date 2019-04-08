#!/bin/bash

if [ "${ACTION}" != "install" ]
then
	exit 0
fi

GIT="$(which git)"
if [ -z "${GIT}" -o ! -x "${GIT}" ]
then
	echo "error: git not found"
	exit 1
fi

DIFF_LINE_COUNT=$(${GIT} status --porcelain | wc -l)
if [ ${DIFF_LINE_COUNT} -ne 0 ]
then
	echo "error: Git repository contains unstaged, uncommited or untracked files. Please commit or stash your changes before continuing."
	exit 1
fi
