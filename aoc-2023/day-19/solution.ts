#!/usr/bin/env -S bun run

const printTrace: bool = false;

// px{a<2006:qkq,m>2090:A,rfg}
function parseFlow(acc: object, raw: string) {
  const [name, rest] = raw.split("{");
  const rules = rest.substring(0, rest.length-1).split(",").map(parseRule);
  return { ...acc, [name]: rules };
}

// [a<2006:qkq, m>2090:A, rfg]
function parseRule(raw: string) {
  const res = raw.match(/([xmas])([><])(\d+):(\w+)/);
  if (res === null) {
    return { target: raw };
  }

  const [_, attr, op, val, target] = res;
  return { attr, op, val: Number(val), target };
}

function parseAttr(acc: object, raw: string) {
  const [ key, value ] = raw.split("=");
  return { ...acc, [key]: Number(value) };
}

function parsePart(raw: string) {
  return raw.substring(1, raw.length-1).split(",").reduce(parseAttr, {});
}

function run(flows: object, part: object, start: string, trace: bool): bool {
  var curr = start;
  if (trace) Bun.write(Bun.stdout, JSON.stringify(part) + ": ");

  while (true) {
    if (curr === "A") {
      if (trace) Bun.write(Bun.stdout, "A\n");
      return true;
    } else if (curr === "R") {
      if (trace) Bun.write(Bun.stdout, "R\n");
      return false;
    }

    if (trace) Bun.write(Bun.stdout, curr + " -> ");
    for (const rule of flows[curr]) {
      var match = false;
      if (!("op" in rule)) {
        match = true;
      } else if (rule.op === ">") {
        match = (part[rule.attr] > rule.val);
      } else if (rule.op === "<") {
        match = (part[rule.attr] < rule.val);
      } else {
        Bun.write(Bun.stderr, "Don't know how to handle rule " + JSON.stringify(rule));
        return false;
      }

      if (match) {
        curr = rule.target;
        break;
      }
    }
  }

  // unreachable?
}

function rate(part: object): number {
  const { x, m, a, s } = part;
  return x + m + a + s;
}



function clonemas(r: object): object {
  var c = {};
  for (const key of Object.keys(r)) {
    c[key] = Object.assign([], r[key]);
  }
  return c;
}

function calcCover(flows: object, start: string): object[] {
  var stack = [];
  stack.push([start, {
    x: [1, 4000],
    m: [1, 4000],
    a: [1, 4000],
    s: [1, 4000],
  }]);
  if (printTrace) Bun.write(Bun.stdout, "\n");

  // BFS? -- traverse a workflow's rules to completion before taking into
  // account the branches of the current workflow. stack semantics instead of
  // queue semantics right?
  //
  // oh shit what am I doing?
  var covers = [];
  while (stack.length > 0) {
    const [curr, span] = stack.pop();

    // "A" accepts the flow
    if (curr === "A") {
      covers.push(clonemas(span));
      continue;
    }
    // "R" gets ignored bc essentially it's [0, 0]
    if (curr == "R") {
      continue;
    }

    for (const rule of flows[curr]) {
      if (!("op" in rule)) {
        // simulate jump to new target for until after all rules in current
        // flow is done
        stack.push([rule.target, clonemas(span)]);
        if (printTrace) Bun.write(Bun.stdout, JSON.stringify(rule) + " ~~ " + JSON.stringify(span) + "\n");

      } else if (rule.op === ">") {
        const [ min, max ] = span[rule.attr];
        // ">" increases the min in the span (+1 bc >, not >=) then push
        // that onto stack
        span[rule.attr] = [Math.max(min, rule.val) + 1, max];
        stack.push([rule.target, clonemas(span)]);
        if (printTrace) Bun.write(Bun.stdout, JSON.stringify(rule) + " (ifTrue) " + JSON.stringify(span) + "\n");

        // this feels risky, but simulate next rule: eval will be because
        // current rule did not match, so flip the conditions on the span
        span[rule.attr] = [min, Math.min(rule.val, max)];
        if (printTrace) Bun.write(Bun.stdout, JSON.stringify(rule) + " (ifFalse) " + JSON.stringify(span) + "\n");

      } else if (rule.op === "<") {
        const [ min, max ] = span[rule.attr];
        // "<" decreases the max (-1 bc <, not <=)
        span[rule.attr] = [min, Math.min(rule.val, max) - 1];
        stack.push([rule.target, clonemas(span)]);
        if (printTrace) Bun.write(Bun.stdout, JSON.stringify(rule) + " (ifTrue) " + JSON.stringify(span) + "\n");

        // simulate next rule: eval will be because current rule did not match,
        // so flip the conditions on the span
        span[rule.attr] = [Math.max(min, rule.val), max];
        if (printTrace) Bun.write(Bun.stdout, JSON.stringify(rule) + " (ifFalse) " + JSON.stringify(span) + "\n");
      }
    }
  }

  // not that bad actually
  return covers;
}

function comboCounter(acc: number, span: object): number {
  return acc + span.reduce((prod, [min, max]) => prod * (max - min + 1), 1);
}



const input = await Bun.readableStreamToText(Bun.stdin.stream());
const [rawFlows, rawParts] = input.split("\n\n");

var flows = rawFlows.split("\n").reduce(parseFlow, {});
var parts = rawParts.split("\n").map(parsePart);
parts.pop(); // blank after last \n

//console.log(JSON.stringify(flows));
//console.log(JSON.stringify(parts));

const pt1 = parts.filter((part) => run(flows, part, "in", printTrace)).map(rate).reduce((acc, v) => acc + v, 0);
Bun.write(Bun.stdout, "Pt1: " + pt1 + "\n");

const pt2 = calcCover(flows, "in").map(Object.values).reduce(comboCounter, 0);
Bun.write(Bun.stdout, "Pt2: " + pt2 + "\n");
