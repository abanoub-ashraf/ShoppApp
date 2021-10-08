// ignore_for_file: file_names

class HTTPException implements Exception {
    final String message;

    HTTPException(this.message);
    
    @override
    String toString() {
        return message;
    }
}