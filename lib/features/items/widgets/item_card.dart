import 'package:flutter/material.dart';
import 'package:swapstash/core/models/item.dart';
import 'package:swapstash/core/services/item_image_service.dart';

class ItemCard extends StatefulWidget {
  final String collectionId;
  final Item item;
  final bool isSaving;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ItemCard({
    super.key,
    required this.collectionId,
    required this.item,
    required this.isSaving,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final ItemImageService _imageService = ItemImageService();

  late Future<String?> _imageUrlFuture;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.collectionId != widget.collectionId ||
        oldWidget.item.number != widget.item.number) {
      _loadImage();
    }
  }

  void _loadImage() {
    _imageUrlFuture = _imageService.getItemImageUrl(
      collectionId: widget.collectionId,
      itemNumber: widget.item.number,
    );
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploadingImage) return;

    debugPrint(
      'Odpiram galerijo za predmet #${widget.item.number}',
    );

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl =
          await _imageService.pickAndUploadItemImage(
        collectionId: widget.collectionId,
        itemNumber: widget.item.number,
      );

      debugPrint('Rezultat: $imageUrl');

      if (!mounted || imageUrl == null) {
        return;
      }

      setState(() {
        _imageUrlFuture = Future.value(imageUrl);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slika uspešno naložena.'),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('NAPAKA: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Napaka pri nalaganju slike:\n$error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final Color backgroundColor;
    final Color foregroundColor;
    final IconData statusIcon;
    final String status;

    if (item.isMissing) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      statusIcon = Icons.remove_circle_outline;
      status = 'Manjka';
    } else if (item.hasDuplicates) {
      backgroundColor = Colors.orange.shade50;
      foregroundColor = Colors.orange.shade800;
      statusIcon = Icons.swap_horiz;
      status = 'Viški: ${item.duplicateCount}';
    } else {
      backgroundColor = Colors.green.shade50;
      foregroundColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
      status = 'Imam';
    }

    return Card(
      margin: EdgeInsets.zero,
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.6),
                      child: FutureBuilder<String?>(
                        future: _imageUrlFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final imageUrl = snapshot.data;

                          if (imageUrl == null) {
                            return Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: foregroundColor,
                              ),
                            );
                          }

                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: foregroundColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isUploadingImage
                            ? null
                            : _pickAndUploadImage,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _isUploadingImage
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: foregroundColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '#${item.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: foregroundColor,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: item.isMissing ||
                          widget.isSaving
                      ? null
                      : widget.onDecrease,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 36,
                  child: Center(
                    child: widget.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,
                              color: foregroundColor,
                            ),
                          ),
                  ),
                ),
                IconButton.filled(
                  onPressed: widget.isSaving
                      ? null
                      : widget.onIncrease,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}