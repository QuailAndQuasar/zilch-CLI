# Zilch CLI Procedural Rules

## Starting the CLI
To start the CLI, run:
```bash
./bin/zilch start
```

## Available Commands

### 1. Test Connection
- Tests the connection to the API server
- Shows detailed response information
- Displays any connection errors

### 2. Start New Game
- Creates a new game
- Returns a game ID
- Handles any creation errors

### 3. Join Game
- Join an existing game
- Requires:
  - Game ID
  - Player Name
- Returns:
  - Player ID
- Error Handling:
  - Game not found
  - Invalid input
  - General API errors

### 4. View Game Status
- Shows current game status
- Displays in table format:
  - Player names
  - Scores
  - Current turn status
- Error Handling:
  - Game not found
  - API errors

### 5. Play Turn
- Complete game turn sequence:
  1. Roll dice
  2. View dice results
  3. Option to end turn
  4. Enter score if ending turn
- Requirements:
  - Game ID
  - Player ID
- Error Handling:
  - Game/player not found
  - Invalid input
  - API errors

## Error Handling
The CLI provides specific error messages for different scenarios:
- `NotFoundError`: Game or player not found
- `ValidationError`: Invalid input data
- `ApiError`: General API communication errors

## Visual Feedback
- Loading spinners for all operations
- Success/error messages
- Formatted tables for game status
- Clear input prompts

## Best Practices
1. Always verify game ID before joining
2. Keep track of your player ID
3. Check game status before taking turns
4. Ensure valid score input when ending turns 

# Procedural Assessment of a Turn (one or more rolls in a turn)
Here’s the same logic laid out in **Markdown**:

---

### 1. Count the dice faces
Roll N dice (usually N = 6), then build a frequency map:  
```text
counts[d] = number of dice showing face d,  for d in 1…6
```

---

### 2. Check for “all-dice” bonuses first
These use **all** N dice in one combo—if you hit one of these, you can stop immediately.

1. **Straight (1-2-3-4-5-6)**  
   - **Condition:** every face 1…6 appears exactly once  
   - **Score:** 1 500 points  

2. **Three pairs**  
   - **Condition:** exactly three different faces each appear twice  
   - **Score:** 1 500 points  

3. **Two triplets**  
   - **Condition:** exactly two different faces each appear three times  
   - **Score:** 2 500 points  

4. **Six of a kind**  
   - **Condition:** some face appears 6×  
   - **Score:** 3 000 points  

---

### 3. Otherwise, look for high-value “of-a-kind” combos
Process in descending order, **removing** dice as you score them:

1. **Five of a kind**  
   - **Condition:** `counts[d] == 5`  
   - **Score:** 2 000 points  
   - Remove those 5 dice; 1 die remains.  

2. **Four of a kind + a pair**  
   - **Condition:** `counts[d] == 4` and `counts[e] == 2` (d ≠ e)  
   - **Score:** 1 500 points  
   - All dice are used.  

3. **Four of a kind**  
   - **Condition:** `counts[d] == 4`  
   - **Score:** 1 000 points  
   - Remove those 4 dice; 2 dice remain.  

4. **Three of a kind**  
   - **Condition:** `counts[d] ≥ 3`  
   - **Score:**  
     - d = 1 → 1 000 points  
     - d = 2…6 → d × 100 points (e.g. three 4’s = 400)  
   - Remove each triplet as you score it; re-check for extra 3+ sets.  

---

### 4. Score any leftover 1’s and 5’s
- Each single **1** = 100 points  
- Each single **5** = 50 points  
- All other single faces = 0 points  

---

### 5. Sum everything
Add together the points from your one big combo **plus** any leftover scoring.

---

### 6. Zilch check
If you found **no** scoring combination (no 1’s, no 5’s, no three-of-a-kind, etc.), the roll is a **Zilch** and scores **0**.

---

### Pseudocode

```pseudo
function score_roll(dice[1…N]):
    counts = histogram(dice)

    # 1. All-dice bonuses
    if counts == {1,1,1,1,1,1}:              # straight
        return 1500
    if exactly_three_pairs(counts):
        return 1500
    if exactly_two_triplets(counts):
        return 2500
    if any counts[d] == 6:
        return 3000

    total = 0

    # 2. Five- and four-kind
    if any counts[d] == 5:
        total += 2000
        counts[d] -= 5

    else if any d,e with counts[d] == 4 and counts[e] == 2:
        total += 1500
        counts[d] = 0
        counts[e] = 0

    else if any counts[d] == 4:
        total += 1000
        counts[d] -= 4

    # 3. Three-of-a-kind
    for d in 1…6:
        while counts[d] >= 3:
            total += (d == 1 ? 1000 : d * 100)
            counts[d] -= 3

    # 4. Single 1’s and 5’s
    total += counts[1] * 100
    total += counts[5] * 50

    # 5. Zilch?
    if total == 0:
        return 0

    return total
```

> **Tip:** This greedy approach—always consuming the highest-value pattern first—guarantees you’ll find the **maximum** score for any Zilch roll.