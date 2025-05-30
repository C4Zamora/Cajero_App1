import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'count_page.dart';
import 'retirar_dinero.dart';
import 'depositos.dart';
import 'transferir.dart';
import 'estado.cuenta.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String nombre = '';
  double saldo = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  void cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          nombre = doc['nombre'];
          saldo = doc['saldo']?.toDouble() ?? 0.0;
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 140, 0, 1),
        title: Text('Bienvenid@, $nombre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFECEFF1)],
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
                              'Cuenta Principal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Saldo disponible',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${saldo.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Última actualización: ahora',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() => loading = true);
                                    cargarDatosUsuario();
                                  },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Actualizar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Acciones rápidas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _actionButton(Icons.arrow_upward, 'Retirar dinero', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RetirosPage()),
                        );
                      }),
                      _actionButton(Icons.arrow_downward, 'Depositar', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DepositoPage()),
                        );
                      }),
                      _actionButton(Icons.swap_horiz, 'Transferir', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransferirPage()),
                        );
                      }),
                      _actionButton(Icons.receipt_long, 'Estado de cuenta', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EstadoCuentaPage()),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Transacciones recientes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTransaccionesRecientes(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildTransaccionesRecientes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('transacciones')
          .orderBy('fecha', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 1,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: const Center(
                child: Text(
                  'No hay transacciones recientes',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        final transacciones = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transacciones.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tx = transacciones[index];
            final tipo = tx['tipo'];
            final monto = tx['monto']?.toDouble() ?? 0.0;
            final fecha = (tx['fecha'] as Timestamp).toDate();

            return ListTile(
              leading: Icon(
                tipo == 'retiro' ? Icons.arrow_upward : Icons.arrow_downward,
                color: tipo == 'retiro' ? Colors.red : Colors.green,
              ),
              title: Text(
                tipo == 'retiro' ? 'Retiro de dinero' : 'Depósito',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Text(
                (tipo == 'retiro' ? '-' : '+') + '\$${monto.toStringAsFixed(2)}',
                style: TextStyle(
                  color: tipo == 'retiro' ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 243, 89, 33),
        elevation: 2,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
