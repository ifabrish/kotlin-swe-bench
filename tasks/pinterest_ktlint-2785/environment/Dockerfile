# Self-contained build for pinterest_ktlint-2785. Base built once by scripts/build_bases.sh.
FROM kotlin-bench/pinterest_ktlint:base

COPY check_git_changes.sh /home/
COPY prepare.sh /home/

RUN bash /home/prepare.sh
RUN chmod +x /home/*.sh

RUN apt-get update -qq && apt-get install -y --no-install-recommends tmux python3 && pip install --quiet asciinema || true
WORKDIR /home/ktlint
