grelease() { git push origin "$(git_current_branch)" && git tag --annotate "$1" -m "$1" && git push origin "$1" }
