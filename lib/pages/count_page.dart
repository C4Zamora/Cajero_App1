import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CountPage extends StatefulWidget {
  const CountPage({super.key});

  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  String nombre = '';
  String numeroCuenta = '';
  double saldo = 0.0;
  bool loading = true;

  List<Map<String, dynamic>> transacciones = [];

  @override
  void initState() {
    super.initState();
    cargarInformacionCuenta();
  }

  Future<void> cargarInformacionCuenta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (docUsuario.exists) {
        final datos = docUsuario.data()!;
        setState(() {
          nombre = datos['nombre'] ?? '';
          numeroCuenta = datos['numeroCuenta'] ?? 'No asignado';
          saldo = (datos['saldo'] ?? 0).toDouble();
        });
      }

      final snapshotTransacciones = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('transacciones')
          .orderBy('fecha', descending: true)
          .get();

      setState(() {
        transacciones = snapshotTransacciones.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Elimina fondo gris al hacer scroll
      appBar: AppBar(
  
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card con degradado
                  Container(
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
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de la cuenta',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Text('Titular: $nombre'),
                          Text('Número de cuenta: $numeroCuenta'),
                          Text(
                            'Saldo disponible: \$${saldo.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Historial de transacciones',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  transacciones.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay transacciones registradas.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transacciones.length,
                          itemBuilder: (context, index) {
                            final tx = transacciones[index];
                            final tipo = tx['tipo'] ?? 'N/A';
                            final monto = (tx['monto'] ?? 0).toDouble();
                            final fecha = tx['fecha']?.toDate();
                            final fechaTexto = fecha != null
                                ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
                                : 'Fecha desconocida';

                            return Card(
                              elevation: 1,
                              child: ListTile(
                                leading: Icon(
                                  tipo == 'retiro'
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: tipo == 'retiro'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                title: Text(
                                  '${tipo[0].toUpperCase()}${tipo.substring(1)} de \$${monto.toStringAsFixed(2)}',
                                ),
                                subtitle: Text(fechaTexto),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
