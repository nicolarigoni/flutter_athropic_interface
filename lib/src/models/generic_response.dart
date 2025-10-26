class GenericResponse<T> {
  bool success;
  String? message;
  T? object;

  GenericResponse(this.success, {this.message, this.object});
}