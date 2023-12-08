#!/usr/bin/env swift

func lcm(_ a: Int, _ b: Int) -> Int {
    return a / gcd(a, b) * b
}

func gcd(_ a: Int, _ b: Int) -> Int {
    var high = max(a, b)
    var low  = min(a, b)
    while low != 0 {
        let tmp = high
        high = low
        low = tmp % high
    }
    return high
}

typealias Node = (name: String, left: String, right: String)

let lines: [String] = AnyIterator { readLine(strippingNewline: true) }.map { $0 }

// Line 1: Path `[RL]+`
// Line 2: Empty
// Lines 3..: NODE = (Left, Right)
let path = lines.first!
let nodesList: [Node] = lines.dropFirst(2).map {
    // NODE = (Left, Right)
    let result = $0.split(separator: " = ")
    // NODE
    let name = String(result.first!)
    // (Left, Right)
    let subnodes = String(result.last!).dropFirst().dropLast().split(separator: ", ")

    return Node(name: name, left: String(subnodes.first!), right: String(subnodes.last!))
}

// name -> Node
let nodes = Dictionary(uniqueKeysWithValues: zip(nodesList.map { $0.name }, nodesList))

func traverse(_ start: String) -> Optional<Int> {
    var steps = 0
    var current = nodes[start]!

    while true {
        for dir in path {
            steps += 1
            switch dir {
              case "L":
                current = nodes[current.left]!
              case "R":
                current = nodes[current.right]!
              default:
                return Optional.none
            }
            if current.name.hasSuffix("Z") {
                return Optional.some(steps)
            }
            if steps > 200_000 {
                return Optional.none
            }
        }
    }
}

let startNodes = nodesList.filter { $0.name.hasSuffix("A") }.map { $0.name }
let allAnswers = startNodes.map(traverse)
let answers = allAnswers.compactMap { value in Int(value!) }
if startNodes.count == answers.count {
    let answer = answers.reduce(1, lcm)
    print("Start nodes are \(startNodes)")
    print("Steps for each start nodes are \(answers)")
    print("Total steps is \(answer)")
} else {
    print("Only found answers for \(answers.count) out of \(startNodes.count) nodes")
}
