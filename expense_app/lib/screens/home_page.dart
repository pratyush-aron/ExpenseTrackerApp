import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _balanceAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _balanceAnimation;
  late Animation<double> _listAnimation;

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Groceries',
      'amount': -85.50,
      'category': 'Food',
      'icon': Icons.local_grocery_store_rounded,
      'color': const Color(0xFF10B981),
      'time': '2h ago',
    },
    {
      'title': 'Salary',
      'amount': 3200.00,
      'category': 'Income',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFF60A5FA),
      'time': '1 day ago',
    },
    {
      'title': 'Coffee',
      'amount': -12.50,
      'category': 'Food',
      'icon': Icons.local_cafe_rounded,
      'color': const Color(0xFFF59E0B),
      'time': '3h ago',
    },
    {
      'title': 'Netflix',
      'amount': -15.99,
      'category': 'Entertainment',
      'icon': Icons.movie_rounded,
      'color': const Color(0xFFEF4444),
      'time': '1 week ago',
    },
    {
      'title': 'Uber',
      'amount': -23.45,
      'category': 'Transport',
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFF8B5CF6),
      'time': '2 days ago',
    },
    {
      'title': 'Investment',
      'amount': 500.00,
      'category': 'Income',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF34D399),
      'time': '3 days ago',
    },
    {
      'title': 'Gym Membership',
      'amount': -49.99,
      'category': 'Health',
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFFF472B6),
      'time': '1 week ago',
    },
    {
      'title': 'Restaurant',
      'amount': -67.80,
      'category': 'Food',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFF06B6D4),
      'time': '4 days ago',
    },
    {
      'title': 'Gas Station',
      'amount': -45.20,
      'category': 'Transport',
      'icon': Icons.local_gas_station_rounded,
      'color': const Color(0xFF8B5CF6),
      'time': '5 days ago',
    },
    {
      'title': 'Freelance Work',
      'amount': 800.00,
      'category': 'Income',
      'icon': Icons.work_rounded,
      'color': const Color(0xFF34D399),
      'time': '6 days ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _balanceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _balanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _balanceAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _balanceAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _balanceAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F2937),
              Color(0xFF374151),
              Color(0xFF4B5563),
              Color(0xFF6B7280),
              Color(0xFF9CA3AF),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCompactOverview(),
                const SizedBox(height: 20),
                // Make transactions list take up most of the screen
                Expanded(flex: 5, child: _buildTransactionList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _balanceAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _balanceAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _balanceAnimation.value)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey! Welcome back',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pratyush Aron',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _buildGlassContainer(
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactOverview() {
    const double totalBudget = 4000.0;
    const double spentAmount = 2847.50;
    const double remainingAmount = totalBudget - spentAmount;
    final double progressPercentage = spentAmount / totalBudget;

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_cardAnimation.value * 0.2),
          child: Opacity(
            opacity: _cardAnimation.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Monthly Budget Remaining Card
                _buildGlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Budget Left',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${remainingAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Color(0xFF34D399),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: \$${spentAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'of \$${totalBudget.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Progress Bar Card
                _buildGlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spending Progress',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progressPercentage * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: progressPercentage > 0.8
                                      ? [
                                          const Color(0xFFF87171),
                                          const Color(0xFFEF4444),
                                        ]
                                      : progressPercentage > 0.6
                                      ? [
                                          const Color(0xFFFBBF24),
                                          const Color(0xFFF59E0B),
                                        ]
                                      : [
                                          const Color(0xFF34D399),
                                          const Color(0xFF10B981),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '15 days left this month',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: AnimatedBuilder(
            animation: _listAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final delay = index * 0.1;
                          final animationValue = math.max(
                            0.0,
                            math.min(
                              1.0,
                              (_listAnimation.value - delay) / (1.0 - delay),
                            ),
                          );

                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - animationValue)),
                            child: Opacity(
                              opacity: animationValue.clamp(0.0, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                child: _buildTransactionItem(
                                  _transactions[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: transaction['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction['icon'],
              color: transaction['color'],
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction['category']} • ${transaction['time']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: transaction['amount'] > 0
                  ? const Color(0xFF34D399).withOpacity(0.2)
                  : const Color(0xFFEF4444).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${transaction['amount'] > 0 ? '+' : ''}\$${transaction['amount'].abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction['amount'] > 0
                    ? const Color(0xFF34D399)
                    : const Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
