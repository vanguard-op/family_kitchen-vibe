import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../utils/constants.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/dashboard_card.dart';

/// Home screen dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<InventoryProvider>().fetchDashboard('kingdom-id');
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<InventoryProvider>().fetchDashboard('kingdom-id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Kitchen'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<InventoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.dashboard == null) {
              return ListView(
                children: [
                  const SkeletonCard(),
                  const SkeletonCard(),
                ],
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(UIConstants.paddingMedium),
              children: [
                DashboardCard(
                  title: 'Low Stock',
                  subtitle: '${provider.dashboard?.lowStock.length ?? 0} items',
                  icon: Icons.warning,
                  items: (provider.dashboard?.lowStock ?? [])
                      .map((item) => {
                            'name': item.name,
                            'value': '${item.quantity} ${item.unit}',
                          })
                      .toList(),
                  onTap: () => Navigator.of(context).pushNamed('/inventory'),
                ),
                DashboardCard(
                  title: 'Expiring Soon',
                  subtitle:
                      '${provider.dashboard?.expiringSoon.length ?? 0} items',
                  icon: Icons.calendar_today,
                  items: (provider.dashboard?.expiringSoon ?? [])
                      .map((item) => {
                            'name': item.name,
                            'value': item.bestBefore.toString().split(' ')[0],
                          })
                      .toList(),
                  onTap: () => Navigator.of(context).pushNamed('/inventory'),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/inventory/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1:
              Navigator.of(context).pushNamed('/inventory');
              break;
            case 2:
              Navigator.of(context).pushNamed('/members');
              break;
            case 3:
              Navigator.of(context).pushNamed('/profile');
              break;
          }
        },
      ),
    );
  }
}
