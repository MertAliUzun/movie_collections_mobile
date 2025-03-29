import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/screens/provider_screen.dart';

class ProviderCard extends StatelessWidget {
  final List<Map<String, dynamic>> providers;
  final bool? isFromWishlist;
  final String? userEmail;

  const ProviderCard({
    Key? key,
    required this.providers,
    this.isFromWishlist,
    this.userEmail,
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
              padding: const EdgeInsets.only(right: 4.0),
              child: ProviderCardItem(
                logoUrl: 'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                name: provider['provider_name'],
                categories: List<String>.from(provider['categories']),
                providerId: int.parse(provider['provider_id']),
                isFromWishlist: isFromWishlist ?? true,
                userEmail: userEmail ?? 'test@test.com',
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
  final int providerId;
  final bool? isFromWishlist;
  final String? userEmail;

  const ProviderCardItem({
    Key? key,
    required this.logoUrl,
    required this.name,
    required this.categories,
    required this.providerId,
    this.isFromWishlist,
    this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('xxxxx' + providerId.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderScreen(
              providerId: providerId,
              providerName: name,
              isFromWishlist: true, //always go to wishlist
              userEmail: userEmail ?? 'test@test.com',
            ),
          ),
        );
      },
      child: SizedBox(
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
                    fontSize: 10, 
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
                        style: const TextStyle(color: Colors.white70, fontSize: 7.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
