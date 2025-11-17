class UploadDto {
  final String createdAt;
  final bool downloadable;
  final String fileName;
  final String id;
  final String mimeType;
  final int sizeBytes;
  final String type;

  UploadDto(
    this.createdAt,
    this.downloadable,
    this.fileName,
    this.id,
    this.mimeType,
    this.sizeBytes,
    this.type,
  );

  factory UploadDto.fromService(Map<String, dynamic> map) {
    return UploadDto(
      map['created_at'] ?? '',
      map['downloadable'] ?? false,
      map['filename'] ?? '',
      map['id'] ?? '',
      map['mime_type'] ?? '',
      int.tryParse(map['size_bytes'].toString()) ?? 0,
      map['type'] ?? '',
    );
  }
}
