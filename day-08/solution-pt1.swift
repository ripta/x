#!/usr/bin/env swift

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

func traverse(start: String, end: String) -> Optional<Int> {
    var steps = 0
    if var current = nodes[start] {
        while true {
            for dir in path {
                steps += 1
                switch dir {
                  case "L":
                    current = nodes[current.left]!
                  case "R":
                    current = nodes[current.right]!
                  default:
                    return .none
                }
                if current.name == end {
                    return .some(steps)
                }
                if steps > 200_000 {
                    return .none
                }
            }
        }
    } else {
        return .none
    }
}

if let answer = traverse(start: "AAA", end: "ZZZ") {
    print("Got out after \(answer) steps")
} else {
    print("Answer not found!")
}
