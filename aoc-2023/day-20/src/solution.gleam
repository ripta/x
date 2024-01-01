import gleam/dict
import gleam/erlang
import gleam/io
import gleam/int
import gleam/list
//import gleam/option.{type Option, None, Some} // syntax highlighting gets angry
import gleam/option.{Option, None, Some}
import gleam/set
import gleam/string
import gleam/queue
import simplifile

pub type Name = String

pub type Level {
  Low
  High
}

pub type State {
  Off
  On
}

pub type Pulse {
  Pulse(name: Name, input: Level, target: Name)
}

pub type PQ = queue.Queue(Pulse)

pub type Hist = dict.Dict(Name, Level)

pub type Mod {
  Btn
  Bcast
  Conj(h: Hist)
  FF(v: State)
  Inv
}

pub type Counts = #(Int, Int)

pub type World = dict.Dict(Name, #(Mod, List(Name)))

pub type SimRes = #(World, Counts)

pub fn eval(m0: Mod, p0: Pulse) -> Option(#(Mod, Level)) {
  case m0 {
    Btn -> Some(#(m0, p0.input))
    Bcast -> Some(#(m0, p0.input))

    FF(s) -> {
      case p0.input {
        High -> None
        Low  -> case s {
          Off -> Some(#(FF(On), High))
          On  -> Some(#(FF(Off), Low))
        }
      }
    }

    Inv -> {
      case p0.input {
        Low -> Some(#(m0, High))
        High -> Some(#(m0, Low))
      }
    }

    Conj(h0) -> {
      let h = dict.insert(h0, p0.name, p0.input)
      case dict.values(h) |> list.all(fn(x) { x == High }) {
        True -> Some(#(Conj(h), Low))
        False -> Some(#(Conj(h), High))
      }
    }
  }
}

// step through until queue empty
pub fn step(q0: PQ, s: SimRes, search: Option(Name)) -> SimRes {
  let #(w0, c0) = s
  case search, queue.pop_front(q0) {
    _, Error(_) -> s

    Some(n0), Ok(#(Pulse(_name, _input, n1), q)) if n0 == n1 -> {
      step(q, #(w0, c0), search)
    }

    _, Ok(#(Pulse(_name, input, target) as p0, q)) -> {
      let c = case input {
        Low  -> #(c0.0 + 1, c0.1)
        High -> #(c0.0, c0.1 + 1)
      }

      case dict.get(w0, target) {
        Error(_) -> step(q, #(w0, c), search)

        Ok(#(m0, ts)) -> {
          case eval(m0, p0) {
            None -> step(q, #(w0, c), search)
            Some(#(m, l)) -> {
              let w = dict.insert(w0, target, #(m, ts))
              let q1 = list.fold(ts, q, fn(accq, t) { queue.push_back(accq, Pulse(target, l, t)) })
              step(q1, #(w, c), search)
            }
          }
        }
      }
    }
  }
}

// one button press
pub fn sim_once(s: SimRes) {
  let press = Pulse("button", Low, "broadcaster")
  queue.new() |> queue.push_back(press) |> step(s, None)
}

// `times` button presses
pub fn sim(start: World, times: Int) -> SimRes {
  list.range(1, times) |> list.fold(#(start, #(0, 0)), fn(prev, _count) { sim_once(prev) })
}

pub fn parse_targets(line: String) -> dict.Dict(String, List(Name)) {
  let assert Ok(#(style, rest)) = string.split_once(line, " -> ")
  let name = case style {
    "%" <> n -> n
    "&" <> n -> n
    n        -> n
  }
  string.split(rest, ", ") |> list.map(fn(v) { #(v, [name]) }) |> dict.from_list()
}

pub fn merge_targets(acc, d) {
  dict.fold(d, acc, fn(c, k, v) {
    dict.update(c, k, fn(x) {
      case x {
        Some(nv) -> list.append(v, nv)
        None     -> v
      }
    })
  })
}

pub type InMap = dict.Dict(Name, List(Name))

pub fn parse_line(rev: InMap, line: String) -> #(Name, #(Mod, List(Name))) {
  let assert Ok(#(style, rest)) = string.split_once(line, " -> ")
  let targets = string.split(rest, ", ")
  case style {
    "broadcaster" -> #(style, #(Bcast, targets))
    "%" <> name   -> #(name, #(FF(Off), targets))
    "&" <> name   -> {
      case dict.get(rev, name) {
        Error(_) -> #(name, #(Inv, targets))
        Ok([_]) -> #(name, #(Inv, targets))
        Ok(xs) -> #(name, #(Conj(xs |> list.map(fn(x) { #(x, Low) }) |> dict.from_list()), targets))
      }
    }
  }
}

pub fn parse_lines(lines: List(String)) -> #(World, InMap) {
  let clean = lines |> list.filter(fn (line) { string.length(line) > 0 })

  let targets = clean |> list.map(parse_targets) |> list.fold(dict.new(), merge_targets)
  let world = clean |> list.map(fn(line) { parse_line(targets, line) }) |> dict.from_list()
  #(world, targets)
}

pub fn count_levels(res: SimRes) -> Int {
  let #(_, #(low, high)) = res
  low * high
}

//
// pt2
//

pub fn lcm(lst: List(Int)) -> Int {
  case lst {
    [x] -> x
    [x, ..xs] -> {
      let y = lcm(xs)
      x * y / gcd(x, y)
    }
  }
}

pub fn gcd(x, y) -> Int {
  case y {
    0 -> x
    _ -> gcd(y, x % y)
  }
}

pub fn traverse_modules(w0: World, in: InMap, ns0: List(String)) {
  let ns = list.flat_map(ns0, fn(n) {
    let ss = case dict.get(in, n) {
      Ok(ss) -> ss
      Error(_) -> []
    }
    case list.all(ss, fn(s) {
      let assert Ok(#(_, sts)) = dict.get(w0, s)
      list.length(sts) == 1
    }) {
      False -> [n]
      True  -> ss
    }
  })
  case ns == ns0 {
    True -> ns0
    False -> traverse_modules(w0, in, ns)
  }
}

pub fn find_of_rxs(w0: World, in: InMap) {
  traverse_modules(w0, in, ["rx"])
}

pub fn check_cycle_rec(w0: World, w1: World, n: Name, d: Int) {
  let #(w2, _) = sim(w1, 1)
  case w2 == w0 {
    True -> d + 1
    False -> check_cycle_rec(w0, w2, n, d + 1)
  }
}

pub fn prevs(w0: World, l: InMap, ns0: List(Name), s0: set.Set(Name)) {
  case ns0 {
    [] -> dict.filter(w0, fn(k, _v) { set.contains(s0, k) })
    _  -> {
      let ns = list.flat_map(ns0, fn(n) {
        let vs = case dict.get(l, n) {
          Error(_) -> []
          Ok(x)    -> x
        }
        list.filter(vs, fn(v) { !set.contains(s0, v) })
      })
      let s = list.fold(ns, s0, set.insert)
      prevs(w0, l, ns, s)
    }
  }
}

pub fn check_cycle(w0: World, l: InMap, n: Name) {
  let w1 = prevs(w0, l, [n], set.new())
  check_cycle_rec(w1, w1, n, 0)
}


pub fn main() {
  let [ filename ] = erlang.start_arguments()
  let assert Ok(raw) = simplifile.read(from: filename)
  let lines = string.split(raw, on: "\n")

  let #(world, lookup) = parse_lines(lines)

  let pt1 = sim(world, 1000) |> count_levels
  io.println("")
  io.println("Pt1: " |> string.append(int.to_string(pt1)))

  let pt2 = find_of_rxs(world, lookup) |> list.map(fn(n) { check_cycle(world, lookup, n) })
  io.println("")
  io.println("Cycles: " |> string.append(string.join(list.map(pt2, int.to_string), ", ")))
  io.println("Pt2: " |> string.append(int.to_string(int.product(pt2))))
}
