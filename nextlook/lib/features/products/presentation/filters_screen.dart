import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../application/product_providers.dart';
import '../data/product_query_params.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  final ProductQueryParams currentParams;

  const FiltersScreen({
    super.key,
    required this.currentParams,
  });

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  late RangeValues _priceRange;
  late String? _selectedCategory;
  late String? _selectedColor;
  late String? _selectedSize;

  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Black', 'color': const Color(0xFF1E1E2D)},
    {'name': 'Navy', 'color': const Color(0xFF1B2A4A)},
    {'name': 'Brown', 'color': const Color(0xFF795548)},
    {'name': 'Beige', 'color': const Color(0xFFD7CCC8)},
    {'name': 'Red', 'color': const Color(0xFFE53935)},
    {'name': 'Blue', 'color': const Color(0xFF1E88E5)},
    {'name': 'Grey', 'color': const Color(0xFF9E9E9E)},
  ];

  final List<String> _availableSizes = ['S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.currentParams.minPrice ?? 0.0,
      widget.currentParams.maxPrice ?? 200.0,
    );
    _selectedCategory = widget.currentParams.category;
    _selectedColor = widget.currentParams.color;
    _selectedSize = widget.currentParams.size;
  }

  void _onReset() {
    setState(() {
      _priceRange = const RangeValues(0.0, 200.0);
      _selectedColor = null;
      _selectedSize = null;
    });
  }

  void _onApply() {
    final updated = widget.currentParams.copyWith(
      category: _selectedCategory,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 200 ? _priceRange.end : null,
      color: _selectedColor,
      size: _selectedSize,
      clearMinPrice: _priceRange.start == 0,
      clearMaxPrice: _priceRange.end == 200,
      clearColor: _selectedColor == null,
      clearSize: _selectedSize == null,
      page: 1,
    );

    ref.read(productListNotifierProvider.notifier).updateQueryParams(updated);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _onReset,
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryPurple,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: darkNavy),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // 1. Price Range Section
            Text(
              'Price Range',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${_priceRange.start.round()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '\$${_priceRange.end.round()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 200,
              divisions: 20,
              activeColor: primaryPurple,
              inactiveColor: Colors.grey[200],
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 16),

            // 2. Category Dropdown
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: Text('All Categories', style: GoogleFonts.poppins(fontSize: 14)),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories', style: GoogleFonts.poppins(fontSize: 14)),
                        ),
                        ...categories.map(
                          (cat) => DropdownMenuItem<String?>(
                            value: cat.slug,
                            child: Text(cat.name, style: GoogleFonts.poppins(fontSize: 14)),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // 3. Color Selection Swatches
            Text(
              'Color',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _availableColors.map((colorItem) {
                final isSelected = _selectedColor == colorItem['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = isSelected ? null : colorItem['name'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? primaryPurple : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: colorItem['color'] as Color,
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Size Selection Chips
            Text(
              'Size',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _availableSizes.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = isSelected ? null : size;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? darkNavy : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? darkNavy : Colors.grey[200]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : darkNavy,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // 5. Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('apply_filters_button'),
                onPressed: _onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
