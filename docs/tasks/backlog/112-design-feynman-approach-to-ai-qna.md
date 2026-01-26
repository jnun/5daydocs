# Task 112: Design Feynman approach to AI QnA

## Problem
A user has a new idea, but hasn't thought it out well.

## Desired Outcome
User runs through the Feynman process to create the ultimate product feature definition.

# FEYNMAN_PROTOCOL: Recursive Project Intelligence

## 1. MISSION
To transform complex technical features into fundamentally sound, jargon-free, actionable tasks by applying the Feynman Technique recursively. This document serves as the logic-gate for all Feature, Task, and Sprint generation.

## 2. THE FOUR-PHASE LOOP (CLI INSTRUCTIONS)

### PHASE 1: The Big Idea (Concept Definition)
- **AI Action:** Prompt the user for the "High-Level Problem."
- **Constraint:** Block all implementation details (e.g., "Use React," "Postgres").
- **Goal:** Identify the **Human Outcome**. 
- **Validation:** "If this feature were a person, what specific job would it be doing?"

### PHASE 2: The ELI5 (Clarity Filter)
- **AI Action:** Rewrite Phase 1 as an explanation for a 12-year-old.
- **Constraint:** Detect jargon. If words like "API," "Backend," "Interface," or "Database" appear, flag them and force a rewrite using analogies (e.g., "A postman," "A filing cabinet").
- **Success Condition:** The explanation must be readable by a non-technical stakeholder.

### PHASE 3: Deconstruction & Gap Audit (The Stress Test)
- **AI Action:** Break the analogy into "Atomic Operations."
- **Logic Gate:** For every piece, the AI must ask the user: *"Do we have the source material/knowledge to build this right now?"*
- **Output Tags:**
    - `[RESOLVED]`: Path is clear.
    - `[STUDY]`: Knowledge gap identified. Requires research task before proceeding.
    - `[GAP]`: Logical inconsistency (e.g., "The mailbox can't sort mail if it doesn't have an address").

### PHASE 4: Recursive Action (The Build Instruction)
- **AI Action:** Convert `[RESOLVED]` items into "Plain English" instructions.
- **Constraint:** No instruction may exceed 10 words.
- **Refinement:** If a task still feels "heavy," trigger a sub-loop back to Phase 3 for that specific task.

## 3. INTEGRATION HOOKS (FOR BASH/PYTHON CLI)

- **Input:** `feynman init --feature "Feature Name"`
- **LLM Integration:** 
    - Use the [OpenAI API](https://platform.openai.com) or [Anthropic SDK](https://docs.anthropic.com) to process the prompts.
    - Pass this `FEYNMAN.md` as "System Context" to ensure the AI adheres to the jargon-filtering rules.
- **State Management:** Save the output as `features/[feature-name]/BLUEPRINT.md`.

## 4. ERROR HANDLING
- **Jargon Detected:** Return error code 1. "Explanation too complex. Revert to analogies."
- **Logic Loop:** If Step 3 reveals a gap, prevent the "Sprint" from being marked as `READY`.



## Testing Criteria
- [ ] [First success criterion]
- [ ] [Second success criterion]
- [ ] [Additional criteria as needed]
