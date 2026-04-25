/// Represents one chapter/section that the server extracted from a PDF.
///
/// Stored at: `uploads/{uploadId}/chapters/{chapterId}`
class PdfChapterModel {
  final String id;
  final String uploadId;
  final String title;
  final int cardCount;
  final int order;

  const PdfChapterModel({
    required this.id,
    required this.uploadId,
    required this.title,
    required this.cardCount,
    required this.order,
  });

  factory PdfChapterModel.fromJson(String id, Map<String, dynamic> json) {
    return PdfChapterModel(
      id: id,
      uploadId: json['uploadId'] as String? ?? '',
      title: json['title'] as String? ?? 'Chapter',
      cardCount: (json['cardCount'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uploadId': uploadId,
        'title': title,
        'cardCount': cardCount,
        'order': order,
      };
}
