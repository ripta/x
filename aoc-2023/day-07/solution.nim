import std/[algorithm, math, setutils, sequtils, strutils, sugar, syncio]

# fixes bug in std/algorithm implementation for x.len == 0 or 1:
# https://github.com/nim-lang/Nim/issues/21177
proc productFix[T](x: openArray[seq[T]]): seq[seq[T]] =
  let l = x.len
  if l == 0:
    return @[]
  result = newSeq[seq[T]]()
  var
    idxs = newSeq[int](l)
    init = newSeq[int](l)
    idx = 0
    next = newSeq[T](l)
  for i in 0 ..< l:
    if len(x[i]) == 0:
      return
    init[i] = len(x[i]) - 1
  idxs = init
  while true:
    while idxs[idx] == -1:
      idxs[idx] = init[idx]
      idx += 1
      if idx == l:
        return
      idxs[idx] -= 1
    for ni, i in idxs:
      next[ni] = x[ni][i]
    result.add(next)
    idx = 0
    idxs[idx] -= 1

# echo(productFix(repeat(@[1, 2, 3], 3)))
# echo(product(repeat(@[1, 2, 3], 3)))
# echo(productFix(repeat(@[1, 2, 3], 2)))
# echo(product(repeat(@[1, 2, 3], 2)))
# echo(productFix(repeat(@[1, 2, 3], 1)))
# echo(product(repeat(@[1, 2, 3], 1)))
assert productFix(repeat(@[1, 2, 3], 1)) == @[@[3], @[2], @[1]]

type HandType = enum
  HighCard
  Pair
  TwoPair
  ThreeofaKind
  FullHouse
  FourofaKind
  FiveofaKind

type Hand = tuple
  cards: string
  bid: int
  typ: HandType
  dominance: seq[int]

proc handTypeFromCounts(counts: seq[int]): HandType =
  case counts[0]:
    of 5: FiveofaKind
    of 4: FourofaKind
    of 3:
      if counts[1] == 2: FullHouse
      else: ThreeofaKind
    of 2:
      if counts[1] == 2: TwoPair
      else: Pair
    else: HighCard

proc handTypeOf(domOrder, cards: string): (HandType, seq[int]) =
  var counts: seq[int]
  var cardSeq = toSeq(cards.items)

  for card in toSet(cards.items):
    counts.add(cardSeq.count(card))

  let typ = handTypeFromCounts(counts.sorted(Descending))
  let dom = collect:
    for card in cards.items:
      domOrder.find(card)

  (typ, dom)

proc permuteHandTypeOf(domOrder, cards: string, without: char): (HandType, seq[int]) =
  var (bestTyp, bestDom) = handTypeOf(domOrder, cards)

  let repeated = repeat(domOrder.filterIt(it != without), cards.count(without))
  for permOrder in productFix(repeated).reversed():
    let candCards = cards.replace($without) & permOrder.join()
    # echo("   subs: " & $permOrder & " cards: " & $candCards)
    let (candTyp, candDom) = handTypeOf(domOrder, candCards)
    if candTyp > bestTyp:
      bestTyp = candTyp
      # bestDom = candDom

  # echo("XX: " & $bestDom)
  (bestTyp, bestDom)

proc byDominance(a, b: seq[int]): int =
  for (x, y) in zip(b, a):
    let v = cmp(x, y)
    if v != 0:
      return v
  return 0

proc byHandType(a, b: Hand): int =
  let v = cmp(a.typ, b.typ)
  if v == 0: byDominance(a.dominance, b.dominance)
  else: v

proc totalScore(hands: seq[Hand], verbose: bool): int =
  # echo(hands.sorted(byHandType))
  let values = collect:
    var rank = 0
    for hand in hands.sorted(byHandType):
      rank = rank + 1
      if verbose:
        echo(rank, " ", hand.cards, " ", hand.bid, " ", hand.typ, " ", hand.dominance)
        # echo(rank, " ", hand.bid)
      rank * hand.bid
  sum(values)

proc solve1(lines: seq[string]): int =
  let hands = collect:
    for line in lines.mapIt(it.split(" ")):
      let (typ, dom) = handTypeOf("AKQJT98765432", line[0])
      (cards: line[0], bid: parseInt(line[1]), typ: typ, dominance: dom)
  totalScore(hands, false)

proc solve2(lines: seq[string]): int =
  let hands = collect:
    for line in lines.mapIt(it.split(" ")):
      let (typ, dom) = permuteHandTypeOf("AKQT98765432J", line[0], 'J')
      (cards: line[0], bid: parseInt(line[1]), typ: typ, dominance: dom)
  totalScore(hands, false)

let input = syncio.readAll(stdin)
let lines = input.splitLines().filterIt(not isEmptyOrWhitespace(it))
echo(solve1(lines))
echo(solve2(lines))
