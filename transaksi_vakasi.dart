class TransaksiVacasi {
  int? id;
  String jenis; // "Kas" atau "Vacasi"
  String judul; // untuk Kas: nama transaksi, untuk Vacasi: keterangan
  int? nominal; // hanya untuk Kas
  String? namaPelatih; // hanya untuk Vacasi
  String? tanggal; // format "yyyy-mm-dd"

  TransaksiVacasi({
    this.id,
    required this.jenis,
    required this.judul,
    this.nominal,
    this.namaPelatih,
    this.tanggal,
  });

  // Konversi ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'judul': judul,
      'nominal': nominal,
      'namaPelatih': namaPelatih,
      'tanggal': tanggal,
    };
  }

  // Buat object dari Map SQLite
  factory TransaksiVacasi.fromMap(Map<String, dynamic> map) {
    return TransaksiVacasi(
      id: map['id'],
      jenis: map['jenis'],
      judul: map['judul'],
      nominal: map['nominal'],
      namaPelatih: map['namaPelatih'],
      tanggal: map['tanggal'],
    );
  }
}
