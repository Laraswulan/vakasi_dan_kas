import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../model/transaksi_vakasi.dart';

class TambahEditKasVacasiLayar extends StatefulWidget {
  final TransaksiVacasi? data;
  const TambahEditKasVacasiLayar({super.key, this.data});

  @override
  State<TambahEditKasVacasiLayar> createState() =>
      _TambahEditKasVacasiLayarState();
}

class _TambahEditKasVacasiLayarState extends State<TambahEditKasVacasiLayar>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _jenis = 'Kas';
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  final _namaPelatihController = TextEditingController();
  final _tanggalController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    if (widget.data != null) {
      _jenis = widget.data!.jenis;
      _judulController.text = widget.data!.judul;
      _nominalController.text = widget.data!.nominal != null
          ? widget.data!.nominal.toString()
          : '';
      _namaPelatihController.text = widget.data!.namaPelatih ?? '';
      _tanggalController.text = widget.data!.tanggal ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _judulController.dispose();
    _nominalController.dispose();
    _namaPelatihController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(milliseconds: 500));

      TransaksiVacasi newData = TransaksiVacasi(
        id: widget.data?.id,
        jenis: _jenis,
        judul: _judulController.text,
        nominal: _jenis == 'Kas'
            ? int.tryParse(_nominalController.text.replaceAll('.', ''))
            : null,
        namaPelatih: _jenis == 'Vakasi' ? _namaPelatihController.text : null,
        tanggal: _jenis == 'Vakasi' ? _tanggalController.text : null,
      );

      if (widget.data == null) {
        await DatabaseHelper.instance.insertData(newData);
      } else {
        await DatabaseHelper.instance.updateData(newData);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.data == null
                      ? 'Data berhasil ditambahkan!'
                      : 'Data berhasil diupdate!',
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.data != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red.shade700,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Data' : 'Tambah Data Baru',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              isEdit
                  ? 'Perbarui ${widget.data!.jenis}'
                  : 'Isi formulir di bawah',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // JENIS DATA CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade700, Colors.red.shade500],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _jenis == 'Kas' ? Icons.attach_money : Icons.event,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Pilih Jenis Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildJenisButton('Kas', Icons.attach_money),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildJenisButton('Vakasi', Icons.event),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FORM CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_document, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Informasi Detail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // JUDUL
                    TextFormField(
                      controller: _judulController,
                      decoration: InputDecoration(
                        labelText: _jenis == 'Kas'
                            ? 'Nama Transaksi / Keterangan'
                            : 'Judul Vakasi',
                        hintText: _jenis == 'Kas'
                            ? 'Contoh: Pembayaran Januari 2026'
                            : 'Contoh: Vakasi ke Bali',
                        prefixIcon: Icon(
                          Icons.title,
                          color: Colors.red.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),

                    const SizedBox(height: 16),

                    // NOMINAL (Kas only)
                    if (_jenis == 'Kas')
                      TextFormField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Nominal',
                          hintText: '0',
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Rp',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close, color: Colors.grey),
                            onPressed: () => _nominalController.clear(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.green.shade700,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Nominal tidak boleh kosong'
                            : null,
                      ),

                    // NAMA PELATIH (Vakasi only)
                    if (_jenis == 'Vakasi') ...[
                      TextFormField(
                        controller: _namaPelatihController,
                        decoration: InputDecoration(
                          labelText: 'Nama Pelatih',
                          hintText: 'Contoh: Ahmad Fauzi',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.red.shade700,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Nama pelatih tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // TANGGAL
                      TextFormField(
                        controller: _tanggalController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Vakasi',
                          hintText: 'Pilih tanggal',
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.red.shade700,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.edit_calendar,
                              color: Colors.red.shade700,
                            ),
                            onPressed: _pickDate,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onTap: _pickDate,
                        validator: (value) => value!.isEmpty
                            ? 'Tanggal tidak boleh kosong'
                            : null,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    disabledBackgroundColor: Colors.red.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEdit ? Icons.save : Icons.add_circle,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambah Data',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              if (!isEdit) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJenisButton(String jenis, IconData icon) {
    final bool isSelected = _jenis == jenis;

    return InkWell(
      onTap: () {
        setState(() {
          _jenis = jenis;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.red.shade700 : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              jenis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.red.shade700 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FORMATTER UNTUK RUPIAH
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String newText = newValue.text.replaceAll('.', '');
    final String formatted = _formatNumber(newText);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';

    final number = int.tryParse(value);
    if (number == null) return value;

    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
