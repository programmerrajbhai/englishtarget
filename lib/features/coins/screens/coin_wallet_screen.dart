import 'package:flutter/material.dart';

import '../../community/screens/community_login_screen.dart';
import '../../community/services/community_api.dart';
import '../services/coin_reward_service.dart';

class CoinWalletScreen extends StatefulWidget {
  const CoinWalletScreen({super.key});

  @override
  State<CoinWalletScreen> createState() => _CoinWalletScreenState();
}

class _CoinWalletScreenState extends State<CoinWalletScreen> {
  static const _green = Color(0xFF008B48);
  static const _ink = Color(0xFF102038);
  static const _mint = Color(0xFFE4F6EF);

  final _history = <Map<String, dynamic>>[];
  final _rules = <Map<String, dynamic>>[];

  Map<String, dynamic>? _wallet;

  bool _busy = false;
  bool _needsLogin = false;
  bool _openingLogin = false;

  String? _error;
  String? _rulesError;
  int? _nextBefore;

  bool get _locked => _busy || _openingLogin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({
    bool claim = false,
    bool more = false,
  }) async {
    if (_locked || !mounted) return;
    if (more && _nextBefore == null) return;

    setState(() {
      _busy = true;
      _error = null;

      if (!more) {
        _rulesError = null;
      }
    });

    try {
      final result = claim
          ? await CoinRewardService.dailyCheckIn()
          : await CoinRewardService.wallet(
        before: more ? _nextBefore : null,
      );

      if (!mounted) return;

      final rows = result['history'];
      final pagination = result['pagination'];
      final daily = result['daily_reward'];

      if (rows is! List ||
          rows.any((row) => row is! Map) ||
          pagination is! Map ||
          daily is! Map) {
        throw Exception('Invalid wallet response');
      }

      final entries = rows
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();

      final rawCursor = pagination['next_before'];
      final cursor = CommunityApi.number(rawCursor);

      setState(() {
        _wallet = result;
        _needsLogin = false;

        if (!more) {
          _history.clear();
        }

        final ids = _history
            .map((entry) => CommunityApi.number(entry['id']))
            .toSet();

        for (final entry in entries) {
          if (ids.add(CommunityApi.number(entry['id']))) {
            _history.add(entry);
          }
        }

        _nextBefore = pagination['has_more'] == true && cursor > 0
            ? cursor
            : null;
      });

      if (claim) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Wallet updated',
            ),
          ),
        );
      }

      // Rules failing must not hide a successfully loaded wallet.
      if (!more) {
        try {
          final rules = await CoinRewardService.rules();

          if (!mounted) return;

          setState(() {
            _rules
              ..clear()
              ..addAll(rules);
            _rulesError = null;
          });
        } on LoginRequired {
          rethrow;
        } catch (error) {
          if (!mounted) return;

          setState(() {
            _rules.clear();
            _rulesError = CommunityApi.errorText(error);
          });
        }
      }
    } on LoginRequired {
      if (!mounted) return;

      setState(() {
        _needsLogin = true;
        _wallet = null;
        _history.clear();
        _rules.clear();
        _nextBefore = null;
        _rulesError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = claim
            ? 'Reward-এর ফল নিশ্চিত করা যায়নি। Refresh করে দেখো। '
            'আবার check-in করলেও একই দিনের duplicate coin হবে না।'
            : CommunityApi.errorText(error);
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _login() async {
    if (_locked) return;

    setState(() => _openingLogin = true);

    try {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const CommunityLoginScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingLogin = false);
      }
    }

    if (mounted) {
      await _load();
    }
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse('$value')?.toLocal();

    if (date == null) return '';

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year}'
        ' · ${two(date.hour)}:${two(date.minute)}';
  }

  IconData _rewardIcon(String code) {
    switch (code) {
      case 'daily_checkin':
        return Icons.calendar_month_rounded;
      case 'lesson_complete':
        return Icons.menu_book_rounded;
      case 'quiz_pass':
        return Icons.quiz_outlined;
      case 'speaking_complete':
        return Icons.mic_none_rounded;
      default:
        return Icons.redeem_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _wallet;

    return Scaffold(
      backgroundColor: _mint,
      appBar: AppBar(
        backgroundColor: _mint,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Coins',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh wallet',
            onPressed: _locked ? null : () => _load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _green,
          onRefresh: () => _load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            children: [
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(color: _green),
                ),

              if (_needsLogin)
                _card(
                  Column(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 42,
                        color: _green,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Coin সংগ্রহ করতে login করো',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _locked ? null : _login,
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ),

              if (_error != null)
                _errorCard(_error!),

              if (wallet != null) ...[
                _balanceCard(wallet),
                const SizedBox(height: 18),
                _dailyCard(wallet),

                _heading('Ways to earn'),

                if (_rulesError != null)
                  _errorCard(
                    'Reward list load হয়নি।\n$_rulesError',
                  )
                else if (_rules.isEmpty)
                  _card(
                    const Text(
                      'Reward settings load হচ্ছে…',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  )
                else
                  ..._rules.map(_ruleCard),

                _heading('Coin History'),

                if (_history.isEmpty)
                  _card(
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text(
                          'এখনো কোনো coin অর্জন করোনি।\n'
                              'Daily check-in দিয়ে শুরু করো!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueGrey,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ..._history.map(_historyCard),

                if (_nextBefore != null)
                  OutlinedButton(
                    onPressed:
                    _locked ? null : () => _load(more: true),
                    child: const Text('Load older history'),
                  ),

                const SizedBox(height: 16),
                const Text(
                  'Daily reward বাংলাদেশ সময় রাত ১২টায় reset হয়।\n'
                      'Coin ও learning XP আলাদা। Cash withdrawal চালু নেই।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard(Map<String, dynamic> wallet) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009D59), Color(0xFF006D3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: Color(0xFFFFD66B),
                size: 34,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your coin balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${CommunityApi.number(wallet['balance'])}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'আজ অর্জন: +${CommunityApi.number(wallet['earned_today'])} coin',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyCard(Map<String, dynamic> wallet) {
    final rule =
    Map<String, dynamic>.from(wallet['daily_reward'] as Map);

    final claimed = rule['claimed_today'] == true;
    final enabled = rule['enabled'] == true;
    final amount = CommunityApi.number(rule['amount']);

    final label = claimed
        ? 'আজকের reward সংগ্রহ করা হয়েছে'
        : enabled
        ? 'Collect $amount coins'
        : 'Reward আপাতত বন্ধ';

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: _green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rule['title']?.toString() ?? 'Daily Check-in',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            claimed
                ? 'আজকের reward পেয়েছ। আগামীকাল আবার এসো।'
                : enabled
                ? 'আজ check-in করে $amount coin সংগ্রহ করো।'
                : 'Daily reward বর্তমানে বন্ধ আছে।',
            style: const TextStyle(
              color: Colors.blueGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _locked || claimed || !enabled
                  ? null
                  : () => _load(claim: true),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(
                claimed
                    ? Icons.check_circle_outline_rounded
                    : Icons.redeem_rounded,
              ),
              label: Text(label, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleCard(Map<String, dynamic> rule) {
    final ready = rule['integration_ready'] == true;
    final active = rule['active'] == true;
    final amount = CommunityApi.number(rule['amount']);

    final status = !ready
        ? 'Coming soon'
        : active
        ? 'Active'
        : 'Paused';

    return _card(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _mint,
            child: Icon(
              _rewardIcon('${rule['code']}'),
              color: _green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rule['title'] ?? 'Reward'}',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${rule['description'] ?? ''}',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _badge('$amount coins', _green, _mint),
                    _badge(
                      status,
                      active ? _green : const Color(0xFF887347),
                      active
                          ? _mint
                          : const Color(0xFFFFF3D8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    return _card(
      Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFFF3CC),
            child: Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFD59A00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['title'] ?? 'Reward'}',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _date(item['created_at']),
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+${CommunityApi.number(item['amount'])}',
            style: const TextStyle(
              color: _green,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return _card(
      Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _locked ? null : () => _load(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: _ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }



}