# The image AIDEV runs this project's suites in (`environment.image` in
# .aidev/project.yaml). AIDEV runs it as `docker run --rm --network none --user
# <uid>:<gid> -v <workspace>:/work`, so everything a suite needs is in the image.
#
# CI's validate-community-submission job runs in alpine:latest and installs
# bash and git at job start; that cannot happen offline, so this image has them
# already, plus GNU coreutils (scripts/compile_badactors.sh uses `head -n -5`).
# The base is alpine:latest as of 2026-10-30, pinned by digest.
# .aidev/runtime/build.sh builds it; the result is pinned as `environment.image`.
FROM alpine@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a
RUN apk add --no-cache bash git coreutils diffutils
# The suite runs as an arbitrary uid with no passwd entry.
ENV HOME=/tmp
