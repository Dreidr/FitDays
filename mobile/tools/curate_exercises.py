import json, pathlib, re
from collections import Counter, defaultdict

SRC = pathlib.Path("assets/data/free_exercises_db.json")
OUT_HOME = pathlib.Path("assets/data/exercises_home.json")
OUT_GYM = pathlib.Path("assets/data/exercises_gym.json")
REPORT = pathlib.Path("assets/data/curation_report.txt")

# ---- tuning knobs ----
HOME_TARGET = 220
GYM_TARGET = 260

# cap how many variations of a "base name" we keep (prevents 25 push-ups)
PER_BASE_CAP_HOME = 4
PER_BASE_CAP_GYM = 5

# per muscle balance caps (prevents all chest or all legs)
PER_MUSCLE_CAP_HOME = 40
PER_MUSCLE_CAP_GYM = 50

# equipment allow-lists
HOME_EQUIP_OK = {
    "body weight",
    "band",
    "resistance band",
    "pull-up bar",
    "kettlebell",     # optional: remove if you want strict home
    "dumbbell",       # optional: remove if you want strict home
}
# If you want HOME to be strict bodyweight-only, set HOME_EQUIP_OK = {"body weight", "band", "resistance band", "pull-up bar"}

GYM_EQUIP_OK = {
    "body weight",
    "band",
    "resistance band",
    "pull-up bar",
    "dumbbell",
    "kettlebell",
    "barbell",
    "cable",
    "machine",
    "smith machine",
    "ez barbell",
    "olympic barbell",
    "medicine ball",
    "stability ball",
    "bosu ball",
    "trap bar",
}

# keywords that indicate "real-life common" exercises
KEYWORDS = [
    # big patterns
    ("squat", 6),
    ("deadlift", 6),
    ("rdl", 6),
    ("hip thrust", 6),
    ("glute bridge", 5),
    ("lunge", 5),
    ("split squat", 6),
    ("step up", 4),

    ("bench press", 6),
    ("push up", 6),
    ("push-up", 6),
    ("dip", 5),

    ("row", 6),
    ("pull up", 6),
    ("pull-up", 6),
    ("lat pulldown", 6),
    ("pulldown", 5),
    ("chin up", 5),
    ("chin-up", 5),

    ("overhead press", 6),
    ("shoulder press", 6),
    ("military press", 6),

    # accessories people actually do
    ("lateral raise", 4),
    ("bicep curl", 4),
    ("curl", 3),
    ("tricep", 4),
    ("extension", 2),
    ("face pull", 4),
    ("rear delt", 4),
    ("calf raise", 4),

    # core staples
    ("plank", 5),
    ("dead bug", 5),
    ("hollow", 4),
    ("crunch", 3),
    ("leg raise", 4),
    ("russian twist", 3),
    ("mountain climber", 3),
]

# avoid niche / overly weird names
NEGATIVE = [
    ("stretch", -3),
    ("release", -3),
    ("massage", -4),
    ("foam", -4),
    ("assisted", -1),
]

def norm(s: str) -> str:
    return (s or "").strip().lower()

def base_name(name: str) -> str:
    """
    Collapse variations so we don't keep 20 near-duplicates.
    Example: "push-up (diamond)" -> "push up"
    """
    n = norm(name)
    n = re.sub(r"[\(\)\[\]\{\}].*?[\)\]\}]", "", n)  # remove bracketed text
    n = re.sub(r"[^a-z0-9\s\-]", " ", n)
    n = n.replace("-", " ")
    n = re.sub(r"\s+", " ", n).strip()

    # collapse some common variants
    for w in ["incline", "decline", "close grip", "wide grip", "neutral grip", "single arm", "single leg", "alternating"]:
        n = n.replace(w, "").strip()
    n = re.sub(r"\s+", " ", n).strip()
    return n

def muscle_primary(ex: dict) -> str:
    pm = ex.get("primaryMuscles") or []
    if isinstance(pm, list) and pm:
        return norm(str(pm[0]))
    return "other"

def equipment(ex: dict) -> str:
    return norm(str(ex.get("equipment") or ""))

def score(ex: dict) -> int:
    name = norm(ex.get("name", ""))
    s = 0
    for k, w in KEYWORDS:
        if k in name:
            s += w
    for k, w in NEGATIVE:
        if k in name:
            s += w
    # slight boost for having instructions
    inst = ex.get("instructions") or []
    if isinstance(inst, list) and len(inst) >= 2:
        s += 1
    return s

def map_to_fitdays(ex: dict) -> dict:
    ex = dict(ex)

    _id = str(ex.get("id") or ex.get("uuid") or ex.get("name") or "")
    name = str(ex.get("name") or "")
    pm = ex.get("primaryMuscles") or []
    sm = ex.get("secondaryMuscles") or []
    inst = ex.get("instructions") or []

    pm_list = [str(x) for x in pm] if isinstance(pm, list) else []
    sm_list = [str(x) for x in sm] if isinstance(sm, list) else []
    inst_list = [str(x) for x in inst] if isinstance(inst, list) else []

    body = pm_list[0] if pm_list else "other"

    return {
        "id": _id,
        "name": name,
        "bodyPart": body,
        "target": body,
        "equipment": str(ex.get("equipment") or ""),
        "gifUrl": "",
        "secondaryMuscles": sm_list,
        "instructions": inst_list,
    }

def curate(all_data: list, equip_ok: set, target: int, per_base_cap: int, per_muscle_cap: int):
    # filter by equipment
    filtered = []
    for ex in all_data:
        eq = equipment(ex)
        if eq in equip_ok:
            filtered.append(ex)

    # sort by score desc
    filtered.sort(key=lambda e: score(e), reverse=True)

    chosen = []
    base_counts = Counter()
    muscle_counts = Counter()

    for ex in filtered:
        if len(chosen) >= target:
            break

        b = base_name(ex.get("name", ""))
        m = muscle_primary(ex)

        if not b:
            continue
        if base_counts[b] >= per_base_cap:
            continue
        if muscle_counts[m] >= per_muscle_cap:
            continue

        chosen.append(ex)
        base_counts[b] += 1
        muscle_counts[m] += 1

    # if still short, relax constraints slightly (fill)
    if len(chosen) < target:
        for ex in filtered:
            if len(chosen) >= target:
                break
            b = base_name(ex.get("name", ""))
            if not b:
                continue
            if base_counts[b] >= (per_base_cap + 2):
                continue
            chosen.append(ex)
            base_counts[b] += 1

    mapped = [map_to_fitdays(ex) for ex in chosen]
    mapped.sort(key=lambda x: norm(x.get("name", "")))
    return mapped, filtered, base_counts, muscle_counts

def main():
    data = json.loads(SRC.read_text(encoding="utf-8"))
    if isinstance(data, dict) and "exercises" in data:
        data = data["exercises"]
    if not isinstance(data, list):
        raise SystemExit("Source JSON must be a list (or {exercises: []}).")

    home, home_pool, home_base, home_muscle = curate(
        data, HOME_EQUIP_OK, HOME_TARGET, PER_BASE_CAP_HOME, PER_MUSCLE_CAP_HOME
    )
    gym, gym_pool, gym_base, gym_muscle = curate(
        data, GYM_EQUIP_OK, GYM_TARGET, PER_BASE_CAP_GYM, PER_MUSCLE_CAP_GYM
    )

    OUT_HOME.parent.mkdir(parents=True, exist_ok=True)
    OUT_HOME.write_text(json.dumps(home, ensure_ascii=False, indent=2), encoding="utf-8")
    OUT_GYM.write_text(json.dumps(gym, ensure_ascii=False, indent=2), encoding="utf-8")

    # report
    lines = []
    lines.append(f"SRC total: {len(data)}\n")

    lines.append(f"HOME pool (equip filtered): {len(home_pool)}")
    lines.append(f"HOME curated: {len(home)}")
    lines.append("HOME top muscles:")
    for k, v in home_muscle.most_common(12):
        lines.append(f"  {k}: {v}")
    lines.append("")

    lines.append(f"GYM pool (equip filtered): {len(gym_pool)}")
    lines.append(f"GYM curated: {len(gym)}")
    lines.append("GYM top muscles:")
    for k, v in gym_muscle.most_common(12):
        lines.append(f"  {k}: {v}")
    lines.append("")

    REPORT.write_text("\n".join(lines), encoding="utf-8")

    print(f"✅ Wrote {len(home)} -> {OUT_HOME}")
    print(f"✅ Wrote {len(gym)}  -> {OUT_GYM}")
    print(f"📝 Report -> {REPORT}")

if __name__ == "__main__":
    main()

