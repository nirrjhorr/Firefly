/// Represents a low-pressure social connection or cooperative activity
/// designed to facilitate human co-regulation without cognitive fatigue or performance anxiety.
class CooperativeActivity {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String iconKey;
  final String description;
  final String evidenceNote;
  final String suggestedInvitation;
  final List<String> suggestedGames;

  const CooperativeActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.iconKey,
    required this.description,
    required this.evidenceNote,
    required this.suggestedInvitation,
    this.suggestedGames = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CooperativeActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Curated cooperative connection activities from Activity Architecture Section 3.6.
const List<CooperativeActivity> kCuratedCooperativeActivities = [
  CooperativeActivity(
    id: 'parallel_quiet',
    title: 'Parallel Quiet (Sit With Someone)',
    subtitle: 'Co-presence with zero conversation pressure',
    category: 'Shared Presence',
    iconKey: 'person.2',
    description: 'Being physically or digitally alongside someone while reading, working, or resting without needing to perform or make small talk.',
    evidenceNote: 'Polyvagal co-regulation occurs through visual proximity and calm acoustic presence, lowering heart rate even in silence.',
    suggestedInvitation: "Would you be up for sitting together in quiet for a bit? No need to talk, just parallel presence.",
  ),
  CooperativeActivity(
    id: 'appreciation_note',
    title: 'Appreciation Micro-Note',
    subtitle: 'Warm gratitude explicitly freeing the other person from replying',
    category: 'Low-Pressure Warmth',
    iconKey: 'heart',
    description: 'Sending a brief, genuine note of appreciation to someone who has supported you, ending with "no need to reply."',
    evidenceNote: 'Kumar & Epley (2023) demonstrated that expressers systematically underestimate how positively recipients feel upon receiving gratitude.',
    suggestedInvitation: "Thinking of you today and so grateful for you. No need to reply at all, just wanted you to know.",
  ),
  CooperativeActivity(
    id: 'coop_games',
    title: 'Cooperative Games & Shared Puzzles',
    subtitle: 'Low-stakes collaborative play where everyone works together',
    category: 'Play & Flow',
    iconKey: 'puzzlepiece',
    description: 'Engaging in non-competitive games where players collaborate towards a shared goal instead of competing against one another.',
    evidenceNote: 'Collaborative play releases oxytocin and redirects anxious hypervigilance into shared playful problem-solving.',
    suggestedInvitation: "Would you want to do a simple puzzle or play a low-key cooperative game together sometime?",
    suggestedGames: [
      'Shared Jigsaw Puzzle',
      'The Mind (Silent card synchronization)',
      'Hanabi (Collaborative fireworks display)',
      'Forbidden Island (Team rescue)',
      'Collaborative Crossword or Wordle',
    ],
  ),
  CooperativeActivity(
    id: 'low_barrier_presence',
    title: 'Low-Barrier Shared Task',
    subtitle: 'Simple presence during routine actions',
    category: 'Gentle Support',
    iconKey: 'cup.and.saucer',
    description: 'Inviting a friend or housemate to simply be in the room while preparing tea, taking a short 5-minute stroll, or tidying one surface.',
    evidenceNote: 'Body doubling reduces executive dysfunction and breaks the isolation paralysis common in depressive dips.',
    suggestedInvitation: "Could you just be around while I make tea or do a small task? Having someone nearby helps.",
  ),
];
