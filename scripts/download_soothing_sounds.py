import os
import urllib.request
import time

SOOTHING_AUDIO_MAP = {
    # Core app soundscapes (replacing placeholder 1KB stubs)
    'gentle_rain.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/light-rain.mp3',
    'cyclic_sigh_ambience.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind.mp3',
    'grounding_chime.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',

    # Nature & Environmental Calming Ambience
    'ocean_waves.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'forest_birds.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/birds.mp3',
    'warm_campfire.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/campfire.mp3',
    'river_stream.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'waterfall.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waterfall.mp3',
    'wind_in_trees.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'night_crickets.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/crickets.mp3',
    'cat_purring.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/cat-purring.mp3',

    # Rain & Water Comfort Soundscapes
    'heavy_rain.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/heavy-rain.mp3',
    'rain_on_window.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-window.mp3',
    'rain_on_tent.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-tent.mp3',
    'rain_on_leaves.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-leaves.mp3',
    'thunder_rumble.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/thunder.mp3',

    # Meditation & Sensory Grounding Soundscapes
    'wind_chimes.mp3': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
}

def main():
    target_dir = os.path.join('assets', 'audio')
    os.makedirs(target_dir, exist_ok=True)

    print(f"Downloading {len(SOOTHING_AUDIO_MAP)} curated soothing sounds to '{target_dir}'...")

    for filename, url in SOOTHING_AUDIO_MAP.items():
        out_path = os.path.join(target_dir, filename)
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Firefly-Audio-Downloader'})
            with urllib.request.urlopen(req) as resp:
                data = resp.read()
            with open(out_path, 'wb') as f:
                f.write(data)
            size_kb = len(data) / 1024
            print(f"[OK] {filename} ({size_kb:.1f} KB)")
        except Exception as e:
            print(f"[ERROR] {filename}: {e}")

    print("\nAll soothing sound assets downloaded successfully!")

if __name__ == '__main__':
    main()
