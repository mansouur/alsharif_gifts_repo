class SanityConfig {
  static const String projectId = 'plo63gzr';
  static const String dataset = 'production';
  static const String apiVersion = '2024-01-01';

  static const String baseUrl =
      'https://$projectId.api.sanity.io/v$apiVersion/data/query/$dataset';

  static String imageUrl(String ref) {
    // ref format: image-<id>-<WxH>-<ext>
    final stripped = ref.replaceFirst('image-', '');
    final parts = stripped.split('-');
    if (parts.length < 3) return '';
    final ext = parts.last;
    final dimensions = parts[parts.length - 2];
    final id = parts.sublist(0, parts.length - 2).join('-');
    return 'https://cdn.sanity.io/images/$projectId/$dataset/$id-$dimensions.$ext';
  }
}
