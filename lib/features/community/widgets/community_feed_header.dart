import 'package:flutter/material.dart';

class CommunityFeedHeader extends StatelessWidget {
  final bool disabled;
  final bool isGuest;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onSignIn;

  const CommunityFeedHeader({
    super.key,
    required this.disabled,
    required this.isGuest,
    required this.onSearch,
    required this.onNotifications,
    required this.onSignIn,
  });

  static const green = Color(0xFF008B48);
  static const ink = Color(0xFF102038);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return ClipRect(
          child: Stack(
            children: [
              Positioned(
                right: -28,
                bottom: -35,
                child: IgnorePointer(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBFECD9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 45,
                bottom: -40,
                child: IgnorePointer(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0x70A8E5CC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ENGLISH TARGET',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF075626),
                              fontSize: compact ? 11 : 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: compact ? 2 : 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _action(
                          icon: Icons.search_rounded,
                          tooltip: 'Search community',
                          onTap: onSearch,
                        ),
                        const SizedBox(width: 10),
                        _action(
                          icon: Icons.notifications_none_rounded,
                          tooltip: 'Notifications',
                          onTap: onNotifications,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFF0E0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Community',
                        style: TextStyle(
                          color: green,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Your learning circle',
                      style: TextStyle(
                        color: ink,
                        fontSize: compact ? 24 : 26,
                        height: 1.15,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Share. Practice. Grow.',
                      style: TextStyle(
                        color: Color(0xFF657E8E),
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isGuest) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: disabled ? null : onSignIn,
                        style: TextButton.styleFrom(
                          foregroundColor: green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          backgroundColor: const Color(0xCCFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Sign in to join'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _action({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x130D5937),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: disabled ? null : onTap,
          constraints: const BoxConstraints.tightFor(
            width: 44,
            height: 44,
          ),
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 25),
          color: green,
          disabledColor: Colors.blueGrey,
        ),
      ),
    );
  }
}