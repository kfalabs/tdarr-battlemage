# Tdarr with Intel Arc Battlemage Support

[![Auto-build on Tdarr version bump](https://github.com/kfalabs/tdarr-battlemage/actions/workflows/docker-image-build.yml/badge.svg)](https://github.com/kfalabs/tdarr-battlemage/actions/workflows/docker-image-build.yml)

## Intro
Tdarr with Inter Arc Battlemage GPU support!

This uses Ubuntu 25.04 (Plucky) as the base image, so it is pretty bleeding edge and may break some flows since the installed packages are more recent.

Tested on a host with Linux 6.12 and 6.17 kernel. It should work with Linux 6.12+.

## Installation
An example docker compose has been provided to get started. Refer to the official repository at: https://github.com/HaveAGitGat/Tdarr for all environment variables/configuration options. Remember that any environment variable set in docker overwrites the config file.

## Note
This repo provides a workflow to automate the build of all new versions of the Tdarr node anytime a new version is available. You can use it in conjunction with the official Tdarr server, as this image only focuses on building a node with full Intel Battlemage support.

If you have any problems, don't hesitate to raise an issue.
