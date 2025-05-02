class Rekening {
  String? id;
  bool? isDeleted;
  String? nomorRekening;
  String? namaBank;
  String? namaPenerima;
  String? userId;
  String? updatedAt;
  String? createdAt;

  Rekening({
    required this.id,
    required this.isDeleted,
    required this.nomorRekening,
    required this.namaBank,
    required this.namaPenerima,
    required this.userId,
    required this.updatedAt,
    required this.createdAt,
  });

  Rekening.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isDeleted = json['isDeleted'];
    nomorRekening = json['nomorRekening'];
    namaBank = json['namaBank'];
    namaPenerima = json['namaPenerima'];
    userId = json['UserId'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isDeleted'] = isDeleted;
    data['nomorRekening'] = nomorRekening;
    data['namaBank'] = namaBank;
    data['namaPenerima'] = namaPenerima;
    data['UserId'] = userId;
    data['updatedAt'] = updatedAt;
    data['createdAt'] = createdAt;
    return data;
  }
}
