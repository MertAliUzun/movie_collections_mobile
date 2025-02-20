import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';

class ProviderCard extends StatelessWidget {
  final List<Map<String, dynamic>> providers;

  const ProviderCard({
    Key? key,
    required this.providers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: providers.map((provider) => 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ProviderCardItem(
                logoUrl: 'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                name: provider['provider_name'],
                categories: List<String>.from(provider['categories']),
              ),
            )
          ).toList(),
        ),
      ),
    );
  }
}

class ProviderCardItem extends StatelessWidget {
  final String logoUrl;
  final String name;
  final List<String> categories;

  const ProviderCardItem({
    Key? key,
    required this.logoUrl,
    required this.name,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  logoUrl,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.broken_image, size: 50, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: categories.map((category) => 
                     Text(
                      category == 'Subscription' ? S.of(context).subscription :
                      category == 'Buy' ? S.of(context).buy :
                      category == 'Rent' ? S.of(context).rent : '($category)',
                      style: const TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                  
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
