# Self-contained build for Hannah-Sten_TeXiFy-IDEA-3810. Base built once by scripts/build_bases.sh.
FROM kotlin-bench/hannah-sten_texify-idea:base

COPY exclude-flaky-tests.gradle.kts /home/
COPY check_git_changes.sh /home/
COPY prepare.sh /home/

RUN bash /home/prepare.sh
RUN chmod +x /home/*.sh

RUN apt-get update -qq && apt-get install -y --no-install-recommends tmux python3 && pip install --quiet asciinema || true
WORKDIR /home/TeXiFy-IDEA
