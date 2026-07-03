#!/usr/bin/env bash
set -euo pipefail
# Rename a Hanami component gem to the Hanami2:: namespace.
# perl (not sed): macOS/BSD sed does not support \b word boundaries. Idempotent.
#
# Shared, un-forked gems keep the Hanami:: namespace and are EXCLUDED from the
# constant rename: Utils, Assets, Helpers, Validations.
# NB: Hanami::View::Helpers and Hanami::Middleware ARE part of the forked gems and
# DO get renamed — only the TOP-LEVEL shared namespaces above are preserved.
#
# Manual steps still required per gem (see the plan's Prerequisite):
#   gemspec spec.name + VERSION constant; entry-file rename/create;
#   Zeitwerk loader repoint; fork Gemfile sibling pins; reactive bare-ref
#   qualification for Assets/Helpers/Validations; sibling-ref reverts in specs.

# 1) Constant rename across lib/ AND spec/, excluding the shared gems.
find lib spec -name '*.rb' -print0 2>/dev/null | xargs -0 perl -pi -e \
  's/\bHanami::(?!(?:Utils|Assets|Helpers|Validations)\b)/Hanami2::/g; s/\bmodule Hanami\b/module Hanami2/g; s/\bclass Hanami\b/class Hanami2/g'

# 2) Qualify bare `Utils::` refs, lib/ ONLY. Utils is the only shared gem that is
#    NEVER a forked gem's own sub-namespace, so this is always safe to blanket-apply.
#    Bare `Utils::Callbacks` resolved via `module Hanami` lexical scope; under
#    `module Hanami2` it must be fully qualified to `Hanami::Utils::…`.
find lib -name '*.rb' -print0 2>/dev/null | xargs -0 perl -pi -e \
  's/(?<![:\w])Utils::/Hanami::Utils::/g'

# NOTE: Assets / Helpers / Validations are NOT auto-qualified here — a forked gem may
# own that sub-namespace (e.g. view owns Hanami::View::Helpers, where bare `Helpers`
# is correct and must stay). Fix those reactively: if the gate/rake shows
# `uninitialized constant Hanami2::…::<Assets|Helpers|Validations>`, and it refers to
# the standalone shared gem, qualify that specific ref to `Hanami::<name>::`.
