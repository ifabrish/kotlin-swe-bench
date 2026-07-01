# Self-contained build for oss-review-toolkit_ort-10691. Base built once by scripts/build_bases.sh.
FROM kotlin-bench/oss-review-toolkit_ort:base

COPY exclude-flaky-tests.gradle /home/
COPY check_git_changes.sh /home/
COPY prepare.sh /home/

RUN bash /home/prepare.sh
RUN chmod +x /home/*.sh

RUN apt-get update -qq && apt-get install -y --no-install-recommends tmux python3 && pip install --quiet asciinema || true
WORKDIR /home/ort
