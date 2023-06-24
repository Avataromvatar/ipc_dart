

class IPCException implements Exception {
  String title;
  String? discription;
  IPCException(this.title, [this.discription]);
}
