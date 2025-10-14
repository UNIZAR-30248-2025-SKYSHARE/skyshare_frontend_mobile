import 'package:flutter/material.dart';

enum FilterType { nombre, valoracion }

class FilterWidget extends StatefulWidget {
  final Function(FilterType, String) onFilterChanged;
  final VoidCallback onClear;

  const FilterWidget({
    super.key,
    required this.onFilterChanged,
    required this.onClear,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;
  int _selectedStars = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _controller.clear();
        _selectedStars = 0;
        widget.onClear();
      }
    });
  }

  void _selectStars(int stars) {
    setState(() {
      if (_selectedStars == stars) {
        _selectedStars = 0;
        widget.onClear();
      } else {
        _selectedStars = stars;
        widget.onFilterChanged(FilterType.valoracion, stars.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Positioned(
      top: 50,
      left: 16,
      right: _isExpanded ? 16 : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isExpanded ? screenWidth - 32 : 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isExpanded
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _toggleFilter,
                      tooltip: 'Cerrar filtros',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    // Mitad izquierda: búsqueda por nombre
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.text_fields, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Nombre...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() => _selectedStars = 0);
                                  }
                                  widget.onFilterChanged(FilterType.nombre, value);
                                },
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _controller.clear();
                                  widget.onClear();
                                },
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Divisor vertical
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.grey[300],
                    ),
                    // Mitad derecha: estrellas
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          final starNumber = index + 1;
                          final isSelected = _selectedStars >= starNumber;
                          return InkWell(
                            onTap: () {
                              if (_controller.text.isNotEmpty) {
                                _controller.clear();
                              }
                              _selectStars(starNumber);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                color: isSelected ? Colors.amber : Colors.grey,
                                size: 22,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _toggleFilter,
                  tooltip: 'Filtrar spots',
                ),
              ),
      ),
    );
  }
}