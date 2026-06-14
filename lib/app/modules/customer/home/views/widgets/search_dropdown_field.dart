import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';
import '../../controllers/home_controller.dart';

class SearchDropdownField extends StatefulWidget {
  final double width;
  final bool isMobile;
  
  const SearchDropdownField({
    Key? key,
    this.width = 400,
    this.isMobile = false,
  }) : super(key: key);

  @override
  State<SearchDropdownField> createState() => _SearchDropdownFieldState();
}

class _SearchDropdownFieldState extends State<SearchDropdownField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _textController = TextEditingController();
  OverlayEntry? _overlayEntry;
  final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    
    // Watch search results and loading state to refresh overlay
    everAll([controller.searchResults, controller.isSearching, controller.showSearchDropdown], (_) {
      if (_focusNode.hasFocus) {
        _updateOverlay();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay removal slightly to allow tapping item
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    } else if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: widget.isMobile ? MediaQuery.of(context).size.width - 32 : widget.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Obx(() {
                if (controller.isSearching.value) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  );
                }

                if (controller.searchResults.isEmpty) {
                  if (_textController.text.trim().isNotEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No products found',
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.border),
                  itemBuilder: (context, index) {
                    final product = controller.searchResults[index];
                    final image = product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Row(
                        children: [
                          if (product.hasDiscount) ...[
                            Text(
                              '\$${product.discountPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        _focusNode.unfocus();
                        _removeOverlay();
                        _textController.clear();
                        controller.clearSearch();
                        Get.toNamed('${AppRoutes.PRODUCT_DETAILS}?id=${product.id}');
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        onChanged: (val) {
          controller.onSearchChanged(val);
          setState(() {});
        },
        onSubmitted: (value) {
          _focusNode.unfocus();
          _removeOverlay();
          controller.applySearch(value);
        },
        decoration: InputDecoration(
          hintText: 'What are you looking for?',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _textController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _textController.clear();
                    controller.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: widget.isMobile ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: widget.isMobile ? const BorderSide(color: AppTheme.border) : BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: widget.isMobile ? const BorderSide(color: AppTheme.border) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
