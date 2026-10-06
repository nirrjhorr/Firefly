import os
import sys
import json
import subprocess

def test_integrity():
    base_dir = r"c:\Users\mdhas\Documents\Firefly"
    audio_dir = os.path.join(base_dir, "assets", "audio")
    catalogue_path = os.path.join(audio_dir, "audio_catalogue.json")
    attributions_path = os.path.join(audio_dir, "ATTRIBUTIONS.md")

    print("==================================================")
    print("FIREFLY AUDIO SANCTUARY INTEGRITY & OFFLINE TEST")
    print("==================================================")

    # 1. Check catalogue existence
    if not os.path.exists(catalogue_path):
        print("[FAIL] audio_catalogue.json not found!")
        sys.exit(1)
    print("[PASS] audio_catalogue.json exists")

    # 2. Check attributions existence
    if not os.path.exists(attributions_path):
        print("[FAIL] ATTRIBUTIONS.md not found!")
        sys.exit(1)
    print("[PASS] ATTRIBUTIONS.md exists")

    with open(catalogue_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    tracks = data.get("tracks", [])
    print(f"[INFO] Total tracks in catalogue: {len(tracks)}")
    if len(tracks) < 25:
        print(f"[FAIL] Expected at least 25 tracks, found {len(tracks)}")
        sys.exit(1)

    required_fields = [
        "id", "title", "category", "subcategory", "description",
        "durationSeconds", "assetPath", "source", "license",
        "creator", "attribution", "tags", "useCases", "evidenceCategory",
        "evidenceNotes", "qualityScore", "loopable", "recommendedVolume",
        "mood", "environment", "sha256", "fileSizeBytes"
    ]

    total_duration = 0.0
    total_size_bytes = 0
    categories = set()
    licenses = set()
    evidence_cats = set()

    for idx, track in enumerate(tracks):
        # Validate fields
        for field in required_fields:
            if field not in track or track[field] is None:
                print(f"[FAIL] Track #{idx} ({track.get('id')}) missing field: {field}")
                sys.exit(1)

        asset_rel = track["assetPath"]
        # Convert asset path to local filepath
        # Flutter asset format: assets/audio/filename.mp3
        local_rel = asset_rel.replace("/", os.sep)
        local_path = os.path.join(base_dir, local_rel)

        if not os.path.exists(local_path):
            print(f"[FAIL] File does not exist: {local_path}")
            sys.exit(1)

        file_size = os.path.getsize(local_path)
        if file_size == 0:
            print(f"[FAIL] File is empty: {local_path}")
            sys.exit(1)

        total_size_bytes += file_size
        total_duration += track["durationSeconds"]
        categories.add(track["category"])
        licenses.add(track["license"])
        evidence_cats.add(track["evidenceCategory"])

    print(f"[PASS] All {len(tracks)} audio files verified on disk.")
    print(f"[PASS] All {len(tracks)} catalogue metadata entries are 100% complete.")
    print(f"[INFO] Total bundled storage footprint: {total_size_bytes / (1024*1024):.2f} MB")
    print(f"[INFO] Total audio playback duration: {total_duration:.1f} seconds ({total_duration/60:.1f} minutes)")
    print(f"[INFO] Categories represented ({len(categories)}): {', '.join(sorted(categories))}")
    print(f"[INFO] Licenses represented ({len(licenses)}): {', '.join(sorted(licenses))}")
    print(f"[INFO] Evidence categories ({len(evidence_cats)}): {', '.join(sorted(evidence_cats))}")

    # 3. Check Playlists referencing
    playlists = [
        ("10-Minute Reset", ["cyclic_sigh_ambience", "gentle_rain", "wind_chimes", "soft_pink_noise"]),
        ("Sleep Preparation", ["calm_brown_noise", "binaural_delta_drone", "rain_on_window", "cat_purring", "ocean_waves"]),
        ("Deep Relaxation", ["binaural_theta_drone", "forest_birds", "river_stream", "warm_campfire"]),
        ("Cognitive Focus", ["soft_pink_noise", "gentle_white_noise", "binaural_alpha_drone", "rhythmic_clock"]),
        ("Rainy Evening", ["gentle_rain", "heavy_rain", "rain_on_window", "rain_on_tent", "thunder_rumble"]),
        ("Forest Sanctuary", ["forest_birds", "wind_in_trees", "walk_on_leaves", "night_crickets"]),
        ("Sensory Grounding", ["grounding_chime", "river_stream", "ocean_waves", "warm_campfire", "walk_in_snow"]),
        ("Oceanic Rest", ["ocean_waves", "underwater_bubbles", "river_stream", "cave_water_droplets"])
    ]

    track_ids = {t["id"] for t in tracks}
    for pl_name, t_ids in playlists:
        for tid in t_ids:
            if tid not in track_ids:
                print(f"[FAIL] Playlist '{pl_name}' references non-existent track: {tid}")
                sys.exit(1)
    print(f"[PASS] All {len(playlists)} curated playlists verified with valid track references.")

    # 4. Check that no HTTP/HTTPS URLs are used for asset playback
    for track in tracks:
        if track["assetPath"].startswith("http"):
            print(f"[FAIL] Remote streaming detected in assetPath: {track['assetPath']}")
            sys.exit(1)
    print("[PASS] 100% offline verification passed. Zero remote dependencies.")

    # 5. Check Bundled Offline Speech Recognition Acoustic Model
    model_dir = os.path.join(base_dir, "assets", "models")
    model_zip = os.path.join(model_dir, "vosk-model-small-en-us-0.15.zip")
    if not os.path.exists(model_zip):
        print(f"[FAIL] Vosk acoustic model archive not found at {model_zip}!")
        sys.exit(1)

    zip_size_mb = os.path.getsize(model_zip) / (1024 * 1024)
    if zip_size_mb < 30.0:
        print(f"[FAIL] Vosk model archive suspiciously small: {zip_size_mb:.2f} MB")
        sys.exit(1)

    import zipfile
    with zipfile.ZipFile(model_zip, "r") as zf:
        corrupt = zf.testzip()
        if corrupt:
            print(f"[FAIL] Corrupted file in Vosk archive: {corrupt}")
            sys.exit(1)
        names = zf.namelist()
        required_entries = ["final.mdl", "disambig_tid.int"]
        for req in required_entries:
            if not any(req in name for name in names):
                print(f"[FAIL] Missing required acoustic entry '{req}' in Vosk model zip!")
                sys.exit(1)
    print(f"[PASS] Bundled Vosk acoustic model archive validated ({zip_size_mb:.2f} MB, {len(names)} files, 100% intact).")

    print("==================================================")
    print("ALL TESTS PASSED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    test_integrity()
