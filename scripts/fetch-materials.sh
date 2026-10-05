#!/usr/bin/env bash
# Download Kmett reading materials into materials/local/<stage>/ for offline browsing.
# Skips existing files; continues on errors. macOS and Linux compatible (bash + curl).
# Does NOT download YouTube videos. Do NOT commit materials/local/ (see .gitignore).
set -u

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
DEST_ROOT="$ROOT/materials/local"
mkdir -p "$DEST_ROOT"

# fetch URL OUTPATH
# OUTPATH is relative to DEST_ROOT
ok=0
fail=0
skip=0

fetch() {
  local url="$1"
  local rel="$2"
  local out="$DEST_ROOT/$rel"
  local dir
  dir="$(dirname "$out")"
  mkdir -p "$dir"
  if [ -f "$out" ] && [ -s "$out" ]; then
    echo "SKIP  $rel"
    skip=$((skip + 1))
    return 0
  fi
  echo "GET   $rel"
  echo "      $url"
  if curl -fsSL --connect-timeout 20 --max-time 120 -o "$out.partial" "$url"; then
    mv "$out.partial" "$out"
    ok=$((ok + 1))
  else
    rm -f "$out.partial"
    echo "FAIL  $rel"
    fail=$((fail + 1))
  fi
}

echo "Downloading into $DEST_ROOT"
echo

# ---- stage 0: prep ----
fetch "https://comonad.com/reader/talks/kmett-2022-functional-futures/" \
  "0-prep/across-the-kmettverse-talk.html"
fetch "https://comonad.com/reader/talks/kmett-2014-on-hask/" \
  "0-prep/on-hask-talk.html"
fetch "https://comonad.com/reader/talks/youtube-hIZxTQP1ifo/" \
  "0-prep/type-classes-vs-the-world-talk.html"
fetch "https://comonad.com/reader/2013/editorial-procrustean-mathematics/" \
  "0-prep/procrustean-mathematics.html"
fetch "https://comonad.com/reader/talks/youtube-8r1lji4Pzsg/" \
  "0-prep/quick-fix-of-comonads-talk.html"

# ---- stage 1: category / functor / nat ----
fetch "https://comonad.com/reader/2006/generalizing-dot/" \
  "1-category-functor-nat/generalizing-dot.html"
fetch "https://comonad.com/reader/2012/natural-deduction-sequent-calculus-and-type-classes/" \
  "1-category-functor-nat/natural-deduction-type-classes.html"
fetch "https://comonad.com/reader/2015/snippets-fmap/" \
  "1-category-functor-nat/free-theorem-fmap.html"
fetch "https://comonad.com/reader/2012/unnatural-transformations-and-quantifiers/" \
  "1-category-functor-nat/unnatural-transformations.html"
fetch "https://comonad.com/reader/" \
  "1-category-functor-nat/comonad-reader-home.html"

# ---- stage 2: monad / comonad / free ----
fetch "https://comonad.com/reader/2008/monads-for-free/" \
  "2-monad-comonad-free/monads-for-free.html"
fetch "https://comonad.com/reader/2008/the-cofree-comonad-and-the-expression-problem/" \
  "2-monad-comonad-free/cofree-comonad.html"
fetch "https://comonad.com/reader/series/free-monads-for-less/" \
  "2-monad-comonad-free/free-monads-for-less-series.html"
fetch "https://comonad.com/reader/2011/free-monads-for-less/" \
  "2-monad-comonad-free/free-monads-for-less-1.html"
fetch "https://comonad.com/reader/2011/free-monads-for-less-2/" \
  "2-monad-comonad-free/free-monads-for-less-2.html"
fetch "https://comonad.com/reader/2011/free-monads-for-less-3/" \
  "2-monad-comonad-free/free-monads-for-less-3.html"
fetch "https://comonad.com/reader/series/monads-from-comonads/" \
  "2-monad-comonad-free/monads-from-comonads-series.html"
fetch "https://comonad.com/reader/2011/monads-from-comonads/" \
  "2-monad-comonad-free/monads-from-comonads-1.html"
fetch "https://comonad.com/reader/2011/monad-transformers-from-comonads/" \
  "2-monad-comonad-free/monads-from-comonads-2.html"
fetch "https://comonad.com/reader/2011/more-on-comonads-as-monad-transformers/" \
  "2-monad-comonad-free/monads-from-comonads-3.html"
fetch "https://comonad.com/reader/2011/a-product-of-an-imperfect-union/" \
  "2-monad-comonad-free/monads-from-comonads-4.html"
fetch "https://comonad.com/reader/2018/the-state-comonad/" \
  "2-monad-comonad-free/state-comonad.html"
fetch "https://comonad.com/reader/2007/parameterized-monads-in-haskell/" \
  "2-monad-comonad-free/parameterized-monads.html"
fetch "https://comonad.com/reader/talks/monad-homomorphisms-zurihac-2016/" \
  "2-monad-comonad-free/monad-homomorphisms-talk.html"
fetch "https://comonad.com/assets/documents/applicative-do.pdf" \
  "2-monad-comonad-free/applicative-do.pdf"
fetch "https://comonad.com/reader/papers/applicative-do/" \
  "2-monad-comonad-free/applicative-do-paper.html"
fetch "https://comonad.com/reader/2013/phoas/" \
  "2-monad-comonad-free/phoas.html"
fetch "https://comonad.com/reader/2015/bound/" \
  "2-monad-comonad-free/bound.html"

# ---- stage 3: adjunction / yoneda / kan ----
fetch "https://comonad.com/reader/2008/representing-adjunctions/" \
  "3-adjunction-yoneda-kan/representing-adjunctions.html"
fetch "https://comonad.com/reader/series/kan-extensions/" \
  "3-adjunction-yoneda-kan/kan-extensions-series.html"
fetch "https://comonad.com/reader/2008/kan-extensions/" \
  "3-adjunction-yoneda-kan/kan-extensions-1.html"
fetch "https://comonad.com/reader/2008/kan-extensions-ii/" \
  "3-adjunction-yoneda-kan/kan-extensions-2.html"
fetch "https://comonad.com/reader/2008/kan-extension-iii/" \
  "3-adjunction-yoneda-kan/kan-extensions-3.html"
fetch "https://comonad.com/reader/2016/adjoint-triples/" \
  "3-adjunction-yoneda-kan/adjoint-triples.html"
fetch "https://comonad.com/reader/2015/categories-of-structures-in-haskell/" \
  "3-adjunction-yoneda-kan/categories-of-structures.html"

# ---- stage 4: recursion schemes ----
fetch "https://comonad.com/reader/2009/recursion-schemes/" \
  "4-recursion-schemes/recursion-schemes-field-guide.html"
fetch "https://comonad.com/reader/2014/recursion-schemes-catamorphisms/" \
  "4-recursion-schemes/catamorphisms.html"
fetch "https://comonad.com/reader/2012/catamorphism-knol/" \
  "4-recursion-schemes/catamorphism-knol.html"
fetch "https://comonad.com/reader/series/chronomorphisms/" \
  "4-recursion-schemes/chronomorphisms-series.html"
fetch "https://comonad.com/reader/2008/generalized-hylomorphisms/" \
  "4-recursion-schemes/chronomorphisms-1.html"
fetch "https://comonad.com/reader/2008/time-for-chronomorphisms/" \
  "4-recursion-schemes/chronomorphisms-2.html"
fetch "https://comonad.com/reader/2008/dynamorphisms-as-chronomorphisms/" \
  "4-recursion-schemes/chronomorphisms-3.html"

# ---- stage 5: optics / profunctor ----
fetch "https://comonad.com/reader/2012/mirrored-lenses/" \
  "5-optics-profunctor/mirrored-lenses.html"
fetch "https://comonad.com/reader/talks/kmett-2011-lenses-functional-imperative/" \
  "5-optics-profunctor/lenses-functional-imperative-talk.html"
fetch "https://comonad.com/reader/talks/kmett-2012-lenses-nyc/" \
  "5-optics-profunctor/lenses-folds-traversals-talk.html"
fetch "https://ekmett.github.io/haskell/Lenses-Folds-and-Traversals-NYC.pdf" \
  "5-optics-profunctor/lenses-folds-traversals-nyc.pdf"
fetch "https://www.haskellcast.com/episode/001-edward-kmett-on-lenses" \
  "5-optics-profunctor/haskellcast-on-lenses.html"
fetch "https://comonad.com/reader/talks/monad-transformer-lenses-warsaw-2016/" \
  "5-optics-profunctor/monad-transformer-lenses-talk.html"
fetch "https://comonad.com/reader/talks/linear-optics-bx-2021/" \
  "5-optics-profunctor/linear-optics-talk.html"
fetch "https://comonad.com/assets/documents/linear-optics-2021.pdf" \
  "5-optics-profunctor/linear-optics-2021.pdf"

# ---- stage 6: advanced / multicategory ----
fetch "https://comonad.com/reader/series/what-constraints-entail/" \
  "6-advanced-multicategory/what-constraints-entail-series.html"
fetch "https://comonad.com/reader/2011/what-constraints-entail-part-1/" \
  "6-advanced-multicategory/what-constraints-entail-1.html"
fetch "https://comonad.com/reader/2011/what-constraints-entail-part-2/" \
  "6-advanced-multicategory/what-constraints-entail-2.html"
fetch "https://comonad.com/reader/talks/there-and-back-again-lambda-world-2018/" \
  "6-advanced-multicategory/there-and-back-again-talk.html"
fetch "https://comonad.com/reader/talks/combinators-yow-2018/" \
  "6-advanced-multicategory/combinators-revisited-talk.html"
fetch "https://comonad.com/reader/series/live-coding/" \
  "6-advanced-multicategory/live-coding-series.html"

echo
echo "Done. ok=$ok skip=$skip fail=$fail"
echo "Files live under materials/local/ (gitignored). See docs/learning-path.md"
exit 0
