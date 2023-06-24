class IPCException implements Exception {
  String title;
  String? discription;
  IPCException(this.title, [this.discription]);
  @override
  String toString() {
    // TODO: implement toString
    return 'IPCException $title${discription != null ? ': $discription' : ''}';
  }
}
