import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EstadoCuentaPage extends StatefulWidget {
  const EstadoCuentaPage({super.key});

  @override
  State<EstadoCuentaPage> createState() => _EstadoCuentaPageState();
}

class _EstadoCuentaPageState extends State<EstadoCuentaPage> {
  String nombre = '';
  String correo = '';
  String numeroCuenta = '';
  double saldo = 0.0;
  bool loading = true;
  List<Map<String, dynamic>> transacciones = [];

  @override
  void initState() {
    super.initState();
    cargarInformacionUsuario();
  }

  Future<void> cargarInformacionUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final correoUsuario = user.email ?? 'Correo no disponible';

      final docUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (docUsuario.exists) {
        final datos = docUsuario.data()!;
        nombre = datos['nombre'] ?? 'Sin nombre';
        numeroCuenta = datos['numeroCuenta'] ?? 'No asignado';
        saldo = (datos['saldo'] ?? 0).toDouble();
        correo = correoUsuario;
      }

      final snapshotTransacciones = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('transacciones')
          .orderBy('fecha', descending: true)
          .get();

      transacciones = snapshotTransacciones.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Resumen de Cuenta'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 140, 0, 1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSaldoCard(),
                  const SizedBox(height: 20),
                  _buildUsuarioInfo(),
                  const SizedBox(height: 24),
                  const Text(
                    'Últimas transacciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildTransaccionesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSaldoCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFFA726), // Naranja suave
          Color(0xFFECEFF1), // Blanco grisáceo
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(2, 4), // Dirección de la sombra
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saldo actual',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '\$${saldo.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'N° de cuenta',
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              numeroCuenta,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  }

  Widget _buildUsuarioInfo() {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              const Icon(Icons.person, color: Color.fromARGB(255, 183, 87, 58)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(nombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.email, color: Color.fromARGB(255, 183, 87, 58)),
              const SizedBox(width: 8),
              Expanded(child: Text(correo)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTransaccionesList() {
    if (transacciones.isEmpty) {
      return const Text(
        'No hay transacciones registradas.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transacciones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transacciones[index];
        final tipo = tx['tipo'] ?? 'N/A';
        final monto = (tx['monto'] ?? 0).toDouble();
        final fecha = tx['fecha']?.toDate();
        final fechaTexto = fecha != null
            ? '${fecha.day}/${fecha.month}/${fecha.year} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
            : 'Sin fecha';

        final esRetiro = tipo.toLowerCase() == 'retiro';

        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: esRetiro ? Colors.red[50] : Colors.green[50],
              child: Icon(
                esRetiro ? Icons.arrow_upward : Icons.arrow_downward,
                color: esRetiro ? Colors.red : Colors.green,
              ),
            ),
            title: Text(
              '${tipo[0].toUpperCase()}${tipo.substring(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(fechaTexto),
            trailing: Text(
              '${esRetiro ? '-' : '+'}\$${monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: esRetiro ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

