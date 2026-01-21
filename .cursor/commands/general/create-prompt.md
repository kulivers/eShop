# Create Prompt

## Overview

Design a high-quality prompt for an AI task that is concise, logical, explicit, adaptive, and reflective.

## Principles

- **Concise**: Brevity and clarity; remove fluff and redundancy.
- **Logical**: Ordered, coherent structure with clear sections.
- **Explicit**: State inputs, constraints, and expected outputs precisely.
- **Adaptive**: Include guidance to iterate based on AI output.
- **Reflection**: Add a short review step to evaluate and refine.

## Steps

1. **Define goal (Concise)**
   - One-sentence objective for the AI.
2. **Specify inputs (Explicit)**
   - List the minimal inputs/context the AI needs.
3. **Constrain output (Explicit)**
   - Format, length, style, audience, acceptance criteria.
4. **Sequence tasks (Logical)**
   - Ordered bullet steps the AI should follow.
5. **Add adaptation loop (Adaptive)**
   - How to revise if results miss the mark.
6. **Add reflection checklist (Reflection)**
   - Quick self-evaluation for completeness and clarity.

## Prompt Template

Copy, fill, and run:

```
Goal:
- <one-sentence objective>

Context (only what is necessary):
- <bulleted key facts/constraints>

Inputs:
- <files/links/data snippets>

Output requirements:
- Format: <e.g., markdown with sections, JSON schema, code file>
- Length: <e.g., <=200 words or <=50 lines>
- Style/Tone: <e.g., professional, direct>
- Audience: <e.g., senior engineer, end user>
- Acceptance criteria: <bullet list>

Process (follow in order):
1) Understand goal and constraints
2) Identify assumptions and ask if critical gaps exist
3) Produce the output to spec
4) Validate against acceptance criteria before finalizing

Adaptation:
- If constraints conflict, state the conflict and propose two alternatives
- If context is insufficient, ask for the minimal missing info in <=3 questions

Reflection (run before final):
- Is the response concise and on-spec?
- Does it follow the requested format and length?
- Are assumptions stated clearly?
- Would a first-time reader understand the result?
```

## Example (Feature spec prompt)

- Goal: "Draft a minimal RFC for adding an audit log endpoint."
- Context: Service is Node/Express; Postgres; must not break existing clients.
- Inputs: `routes/audit.ts`, DB schema link, sample events.
- Output: Markdown RFC (<=300 words) with Overview, API, Data Model, Risks.
- Process: Understand -> Draft -> Validate.
- Adaptation: If auth model unclear, provide two auth options.
- Reflection: Check format, length, clarity, and explicit risks.

## Checklist

- [ ] Objective is one sentence and unambiguous
- [ ] Only essential context is included
- [ ] Output format and acceptance criteria are explicit
- [ ] Steps are ordered and coherent
- [ ] Adaptation and reflection prompts are present
