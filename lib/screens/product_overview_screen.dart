import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_grid.dart';
import '../widgets/badge_label.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';

enum filterOptions { Favorite, All }

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context)
          .fetchAndSetProducts()
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          })
          .catchError((error) {
            // Handle error if needed
            showDialog<Null>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('An error occured!'),
                content: Text('Something went wrong. Please try again later.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Okay'),
                  ),
                ],
              ),
            );
          });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop App'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == filterOptions.Favorite) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: filterOptions.Favorite,
                child: Text('Only Favorites'),
              ),
              PopupMenuItem(value: filterOptions.All, child: Text('Show All')),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cart, child) =>
                BadgeLabel(value: cart.itemCount.toString(), child: child!),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductGrid(showFavs: _showOnlyFavorites),
    );
  }
}
