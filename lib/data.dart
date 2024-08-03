class pdftoword {
  int? conversionCost;
  List<Files>? files;

  pdftoword({this.conversionCost, this.files});

  pdftoword.fromJson(Map<String, dynamic> json) {
    conversionCost = json['ConversionCost'];
    if (json['Files'] != null) {
      files = <Files>[];
      json['Files'].forEach((v) {
        files!.add(new Files.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ConversionCost'] = this.conversionCost;
    if (this.files != null) {
      data['Files'] = this.files!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Files {
  String? fileName;
  String? fileExt;
  int? fileSize;
  String? fileData;

  Files({this.fileName, this.fileExt, this.fileSize, this.fileData});

  Files.fromJson(Map<String, dynamic> json) {
    fileName = json['FileName'];
    fileExt = json['FileExt'];
    fileSize = json['FileSize'];
    fileData = json['FileData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileName'] = this.fileName;
    data['FileExt'] = this.fileExt;
    data['FileSize'] = this.fileSize;
    data['FileData'] = this.fileData;
    return data;
  }
}
