import 'dart:convert';
import 'dart:io';

// Direct standalone test to verify catalog and JSON parsing without flutter_test SDK dependency
void main() {
  stdout.writeln('--- Running Standalone Activity Catalog Verification ---');

  final file = File('assets/data/curated_activities.json');
  if (!file.existsSync()) {
    stderr.writeln('FAILED: assets/data/curated_activities.json does not exist!');
    exit(1);
  }

  final content = file.readAsStringSync();
  final dynamic decoded = jsonDecode(content);
  if (decoded is! List) {
    stderr.writeln('FAILED: JSON is not a List!');
    exit(1);
  }

  stdout.writeln('Total activities found: ${decoded.length}');
  assert(decoded.length >= 50, 'Must have at least 50 activities');

  final categories = <String>{};
  for (var i = 0; i < decoded.length; i++) {
    final dynamic item = decoded[i];
    if (item is! Map<String, dynamic>) {
      stderr.writeln('FAILED: Item $i is not a Map!');
      exit(1);
    }

    final id = item['id'] as String?;
    final title = item['title'] as String?;
    final description = item['description'] as String?;
    final category = item['category'] as String?;
    final energy = item['energyRequired'] as int?;
    final targetStates = item['targetStates'] as List<dynamic>?;
    final guidanceType = item['guidanceType'] as String?;
    final evidenceLevel = item['evidenceLevel'] as String?;
    final route = item['route'] as String?;

    if (id == null || id.isEmpty) throw Exception('Item $i missing id');
    if (title == null || title.isEmpty) throw Exception('Item $i missing title');
    if (description == null || description.isEmpty) throw Exception('Item $i missing description');
    if (category == null || category.isEmpty) throw Exception('Item $i missing category');
    if (energy == null || energy < 1 || energy > 5) throw Exception('Item $i invalid energy');
    if (targetStates == null || targetStates.isEmpty) throw Exception('Item $i missing targetStates');
    if (guidanceType == null || guidanceType.isEmpty) throw Exception('Item $i missing guidanceType');
    if (evidenceLevel == null || evidenceLevel.isEmpty) throw Exception('Item $i missing evidenceLevel');
    if (route == null || route.isEmpty) throw Exception('Item $i missing route');

    categories.add(category);
  }

  stdout.writeln('Categories verified (${categories.length}):');
  for (final cat in categories) {
    stdout.writeln('  - $cat');
  }

  stdout.writeln('\nSUCCESS: All ${decoded.length} activities parsed and validated with 100% integrity.');
}
