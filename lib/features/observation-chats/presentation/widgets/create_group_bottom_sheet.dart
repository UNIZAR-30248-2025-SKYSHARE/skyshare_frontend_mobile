import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/observation_chats_provider.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({Key? key}) : super(key: key);

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Función para enviar el formulario
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validación falló
    }
    
    setState(() => _isLoading = true);

    final provider = context.read<ObservationChatsProvider>();
    final success = await provider.createGroup(
      _nameController.text,
      _descriptionController.text,
    );

    if (!mounted) return; // Comprobación de seguridad

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(); // Cierra el bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo "${_nameController.text}" creado con éxito.'),
          backgroundColor: Colors.green[600],
        ),
      );
    } else {
      // Muestra un error si falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al crear el grupo. Inténtalo de nuevo.'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Replicando el estilo de tu app
    const cardColor = Color(0xFF2A2A3D);
    const primaryColor = Color(0xFF6A4D9C);

    return Padding(
      // Padding para que el teclado no tape el formulario
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Título ---
            const Text(
              'Crear Nuevo Grupo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // --- Campo de Nombre ---
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                hintText: 'Nombre del grupo (ej: EINA)',
                icon: Icons.group,
                fillColor: cardColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // --- Campo de Descripción ---
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                hintText: 'Descripción (ej: Grupo de observación EUPT)',
                icon: Icons.description_outlined,
                fillColor: cardColor,
              ),
              // La descripción es opcional, sin validador
            ),
            const SizedBox(height: 24),

            // --- Botón de Crear ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox( // Spinner de carga
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      'Crear Grupo',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16), // Espacio inferior
          ],
        ),
      ),
    );
  }
  
  // Helper para unificar el estilo de los TextFields
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required Color fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF6A4D9C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}