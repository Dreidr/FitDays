import json
import random
from collections import defaultdict, Counter
from pathlib import Path

INPUT_PATH = Path("assets/data/original.json")   
OUTPUT_PATH = Path("assets/data/exercises_curated_200.json")
TOTAL = 200
SEED = 42

# If you want stronger control, set minimum per category here:
MIN_PER_CAT = {
    "cardio": 40,
    "stretching": 40,
    # everything else will fall into "strength"
    "strength": 80,
}

def load_items(path: Path):
    raw = path.read_text(encoding="utf-8")
    decoded = json.loads(raw)
    if isinstance(decoded, list):
        return decoded
    if isinstance(decoded, dict) and isinstance(decoded.get("exercises"), list):
        return decoded["exercises"]
    raise ValueError("Unexpected JSON shape. Expected a list or {'exercises': [...]}")

def normalize_category(cat: str) -> str:
    c = (cat or "").strip().lower()
    if c == "cardio":
        return "cardio"
    if c == "stretching":
        return "stretching"
    # treat everything else as strength lane (powerlifting, plyometrics, etc.)
    return "strength"

def simplify_item(ex: dict) -> dict:
    # Keep what your app needs + what you asked for (images + category)
    primary = ex.get("primaryMuscles") or []
    secondary = ex.get("secondaryMuscles") or []
    instructions = ex.get("instructions") or []
    images = ex.get("images") or []

    # Choose a stable id
    ex_id = ex.get("id") or ex.get("uuid") or ex.get("name") or ""
    name = ex.get("name") or ""

    category = normalize_category(ex.get("category"))
    equipment = (ex.get("equipment") or "").strip()

    # Your app uses bodyPart/target; for this dataset, primary muscle is a good stand-in.
    body_part = primary[0] if isinstance(primary, list) and primary else "other"

    return {
        "id": str(ex_id),
        "name": str(name),
        "category": category,
        "bodyPart": str(body_part),
        "target": str(body_part),
        "equipment": str(equipment),
        "primaryMuscles": [str(x) for x in primary] if isinstance(primary, list) else [],
        "secondaryMuscles": [str(x) for x in secondary] if isinstance(secondary, list) else [],
        "instructions": [str(x) for x in instructions] if isinstance(instructions, list) else [],
        "images": [str(x) for x in images] if isinstance(images, list) else [],
        "level": (ex.get("level") or "").strip(),
        "force": (ex.get("force") or ""),
        "mechanic": (ex.get("mechanic") or ""),
    }

def is_valid(ex: dict) -> bool:
    return bool(ex.get("id")) and bool(ex.get("name"))

def pick_balanced(items, total, seed):
    random.seed(seed)

    # group by normalized category bucket
    buckets = defaultdict(list)
    for ex in items:
        cat = normalize_category(ex.get("category"))
        buckets[cat].append(ex)

    # shuffle each bucket for randomness
    for cat in buckets:
        random.shuffle(buckets[cat])

    # enforce minimums but never exceed total
    chosen = []
    used_ids = set()

    def take_from(cat, n):
        nonlocal chosen
        for ex in buckets.get(cat, []):
            if len(chosen) >= total or n <= 0:
                break
            ex_id = ex.get("id")
            if not ex_id or ex_id in used_ids:
                continue
            chosen.append(ex)
            used_ids.add(ex_id)
            n -= 1

    # Step A: take mins
    mins = dict(MIN_PER_CAT)
    # If total mins exceed TOTAL, scale down proportionally
    sum_mins = sum(mins.values())
    if sum_mins > total:
        scale = total / sum_mins
        for k in mins:
            mins[k] = int(mins[k] * scale)

    take_from("cardio", mins.get("cardio", 0))
    take_from("stretching", mins.get("stretching", 0))
    take_from("strength", mins.get("strength", 0))

    # Step B: fill remaining from all buckets round-robin
    cats = ["strength", "cardio", "stretching"]
    idx = 0
    while len(chosen) < total:
        cat = cats[idx % len(cats)]
        idx += 1
        # find next unused item in bucket
        found = False
        for ex in buckets.get(cat, []):
            ex_id = ex.get("id")
            if ex_id and ex_id not in used_ids:
                chosen.append(ex)
                used_ids.add(ex_id)
                found = True
                break
        if not found:
            # if this bucket is exhausted, try any bucket
            any_found = False
            for other in cats:
                for ex in buckets.get(other, []):
                    ex_id = ex.get("id")
                    if ex_id and ex_id not in used_ids:
                        chosen.append(ex)
                        used_ids.add(ex_id)
                        any_found = True
                        break
                if any_found:
                    break
            if not any_found:
                break  # no more unique items

    return chosen

def main():
    items = load_items(INPUT_PATH)
    # keep only valid items
    items = [ex for ex in items if isinstance(ex, dict) and is_valid(ex)]

    # pick 200 balanced
    chosen_raw = pick_balanced(items, TOTAL, SEED)

    # simplify + normalize
    curated = [simplify_item(ex) for ex in chosen_raw]

    # report
    counts = Counter([c["category"] for c in curated])
    print("Curated category counts:", dict(counts))
    print("Total:", len(curated))
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(curated, indent=2), encoding="utf-8")
    print("Wrote:", OUTPUT_PATH)

if __name__ == "__main__":
    main()
