import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/providers/favorite_provider.dart';

class DestinationCard extends StatefulWidget {
  final String image;
  final String title;
  final double rating;
  final VoidCallback onTap;
  final String placeId;

  const DestinationCard({
    super.key,
    required this.image,
    required this.title,
    required this.rating,
    required this.onTap,
    required this.placeId,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _localFavoriteState = false;

  @override
  void initState() {
    super.initState();
    // We'll set the initial state when the widget is built
  }

  @override
  Widget build(BuildContext context) {
    // Get the provider without listening to changes (listen: false)
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    // Only initialize the local state once
    if (!mounted) return const SizedBox();

    // Only get the initial state from provider, then manage locally
    if (!_localFavoriteState) {
      _localFavoriteState = favoriteProvider.isFavorite(widget.placeId);
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: Icon(
                _localFavoriteState ? Iconsax.heart5 : Iconsax.heart,
                size: 20,
                color: _localFavoriteState ? Colors.red : null,
              ),
              onPressed: () {
                // Update local state immediately for instant UI feedback
                setState(() {
                  _localFavoriteState = !_localFavoriteState;
                });

                // Tell the provider about the change but don't wait
                favoriteProvider.toggleFavorite(widget.placeId);
              },
              constraints: const BoxConstraints(
                minHeight: 32,
                minWidth: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
