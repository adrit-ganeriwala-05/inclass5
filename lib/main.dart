import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PetApp());
}

// ─────────────────────────────── App Root ────────────────────────────────────

class PetApp extends StatelessWidget {
  const PetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petchi',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      ),
      home: const OnboardingScreen(),
    );
  }
}

// ─────────────────────────────── Onboarding ──────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please give your pet a name!"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => PetHomeScreen(petName: name),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // App Icon / Hero
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/pet_image.png',
                        height: 72,
                        errorBuilder: (_, __, ___) => const Text(
                          '🐾',
                          style: TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Petchi',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your virtual companion awaits.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[500],
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Name Field Card
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NAME YOUR PET',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6C63FF),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CupertinoTextField(
                          controller: _nameController,
                          placeholder: 'e.g. Mochi, Pixel, Biscuit…',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1C1C1E),
                          ),
                          placeholderStyle: TextStyle(
                            fontSize: 17,
                            color: Colors.grey[400],
                          ),
                          decoration: const BoxDecoration(),
                          padding: EdgeInsets.zero,
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _continue(),
                        ),
                        const Divider(height: 20, thickness: 0.5),
                        Text(
                          'You can rename your pet anytime in Settings.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: _continue,
                      child: const Text(
                        'Meet Your Pet →',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Home Screen ─────────────────────────────────

class PetHomeScreen extends StatefulWidget {
  final String petName;
  const PetHomeScreen({super.key, required this.petName});

  @override
  State<PetHomeScreen> createState() => _PetHomeScreenState();
}

class _PetHomeScreenState extends State<PetHomeScreen>
    with TickerProviderStateMixin {
  late String petName;
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 100;

  // Activity selection
  _PetActivity _selectedActivity = _PetActivity.run;

  Timer? _timer;
  int _winTimeCounter = 0;
  bool _gameOver = false;
  bool _gameWon = false;

  // Pet bounce animation
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  // Reaction emoji pop animation
  late AnimationController _reactionCtrl;
  late Animation<double> _reactionScale;

  // Idle float animation
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  String _reactionEmoji = '';

  @override
  void initState() {
    super.initState();
    petName = widget.petName;

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    _reactionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _reactionScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reactionCtrl, curve: Curves.elasticOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceCtrl.dispose();
    _reactionCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameOver || _gameWon) return;
      setState(() {
        if (timer.tick % 30 == 0) {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          if (hungerLevel >= 100) {
            happinessLevel = (happinessLevel - 20).clamp(0, 100);
          }
        }

        if (happinessLevel > 80) {
          _winTimeCounter++;
          if (_winTimeCounter >= 180) {
            _gameWon = true;
            HapticFeedback.mediumImpact();
          }
        } else {
          _winTimeCounter = 0;
        }

        if (hungerLevel >= 100 && happinessLevel <= 10) {
          _gameOver = true;
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _triggerBounce() {
    _bounceCtrl.forward().then((_) => _bounceCtrl.reverse());
  }

  void _showReaction(String emoji) {
    setState(() => _reactionEmoji = emoji);
    _reactionCtrl.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _reactionCtrl.reverse();
      });
    });
  }

  void _playWithPet() {
    if (_gameOver || _gameWon || energyLevel < 20) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    _triggerBounce();
    _showReaction('🎉');
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      energyLevel = (energyLevel - 20).clamp(0, 100);
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
    });
  }

  void _feedPet() {
    if (_gameOver || _gameWon) return;
    HapticFeedback.mediumImpact();
    _triggerBounce();
    _showReaction('😋');
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      energyLevel = (energyLevel + 10).clamp(0, 100);
      if (hungerLevel < 30) {
        happinessLevel = (happinessLevel - 10).clamp(0, 100);
      } else {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
      }
    });
  }

  void _petThePet() {
    if (_gameOver || _gameWon) return;
    HapticFeedback.lightImpact();
    _triggerBounce();
    _showReaction('💕');
    setState(() {
      happinessLevel = (happinessLevel + 5).clamp(0, 100);
    });
  }

  void _doActivity() {
    if (_gameOver || _gameWon) return;
    final a = _selectedActivity;
    if (energyLevel < a.energyCost) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Not enough energy for ${a.label}! Feed ${petName.split(' ').first} first.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    _triggerBounce();
    _showReaction(a.reaction);
    setState(() {
      happinessLevel = (happinessLevel + a.happinessDelta).clamp(0, 100);
      hungerLevel = (hungerLevel + a.hungerDelta).clamp(0, 100);
      energyLevel = (energyLevel - a.energyCost + a.energyGain).clamp(0, 100);
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => SettingsScreen(
          currentName: petName,
          onRename: (name) => setState(() => petName = name),
          onReset: _resetGame,
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      energyLevel = 100;
      _winTimeCounter = 0;
      _gameOver = false;
      _gameWon = false;
    });
  }

  // ── Derived state ──────────────────────────────────────────────────────────

  Color get _moodColor {
    if (happinessLevel > 70) return const Color(0xFF34C759);
    if (happinessLevel >= 30) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF3B30);
  }

  String get _moodLabel {
    if (happinessLevel > 70) return 'Happy';
    if (happinessLevel >= 30) return 'Neutral';
    return 'Unhappy';
  }

  String get _moodEmoji {
    if (happinessLevel > 70) return '😄';
    if (happinessLevel >= 30) return '😐';
    return '😢';
  }

  int get _winSecondsLeft => max(0, 180 - _winTimeCounter);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      scrolledUnderElevation: 0,
      expandedHeight: 60,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        title: const Text(
          'Petchi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.8,
          ),
        ),
      ),
      actions: [
        CupertinoButton(
          padding: const EdgeInsets.only(right: 16),
          onPressed: _openSettings,
          child: const Icon(
            CupertinoIcons.settings,
            color: Color(0xFF6C63FF),
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildPetCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildActionsCard(),
          const SizedBox(height: 16),
          _buildActivityCard(),
          if (_gameOver || _gameWon) ...[
            const SizedBox(height: 16),
            _buildOutcomeCard(),
          ],
          if (happinessLevel > 80 && !_gameWon && !_gameOver) ...[
            const SizedBox(height: 12),
            _buildWinProgress(),
          ],
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildPetCard() {
    return _GlassCard(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _moodColor.withOpacity(0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Floating pet
              AnimatedBuilder(
                animation: Listenable.merge([_floatAnim, _bounceAnim]),
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnim.value),
                    child: Transform.scale(
                      scale: _bounceAnim.value,
                      child: GestureDetector(
                        onTap: _petThePet,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: _moodColor.withOpacity(0.3),
                                blurRadius: 24,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Center(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _moodColor.withOpacity(0.15),
                                BlendMode.srcATop,
                              ),
                              child: Image.asset(
                                'assets/pet_image.png',
                                height: 88,
                                errorBuilder: (_, __, ___) => Text(
                                  _moodEmoji,
                                  style: const TextStyle(fontSize: 64),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Reaction emoji pop
              Positioned(
                top: 0,
                right: 20,
                child: AnimatedBuilder(
                  animation: _reactionScale,
                  builder: (_, __) => Transform.scale(
                    scale: _reactionScale.value,
                    child: Text(
                      _reactionEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            petName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1E),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _moodColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_moodEmoji  $_moodLabel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _moodColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap ${petName.split(' ').first} to show some love!',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VITALS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            icon: CupertinoIcons.heart_fill,
            label: 'Happiness',
            value: happinessLevel,
            color: const Color(0xFFFF3B30),
          ),
          const SizedBox(height: 14),
          _StatRow(
            icon: CupertinoIcons.flame_fill,
            label: 'Hunger',
            value: hungerLevel,
            color: const Color(0xFFFF9F0A),
            invert: true,
          ),
          const SizedBox(height: 14),
          _StatRow(
            icon: CupertinoIcons.bolt_fill,
            label: 'Energy',
            value: energyLevel,
            color: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    final canPlay = energyLevel >= 20 && !_gameOver && !_gameWon;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ActionButton(
                icon: CupertinoIcons.sportscourt_fill,
                label: 'Play',
                sublabel: 'Needs 20 energy',
                color: const Color(0xFF6C63FF),
                enabled: canPlay,
                onTap: _playWithPet,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: CupertinoIcons.cart_fill,
                label: 'Feed',
                sublabel: 'Reduces hunger',
                color: const Color(0xFFFF9F0A),
                enabled: !_gameOver && !_gameWon,
                onTap: _feedPet,
              ),
            ],
          ),
          if (!canPlay && energyLevel < 20 && !_gameOver && !_gameWon)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.info_circle,
                      size: 14, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 6),
                  Text(
                    '${petName.split(' ').first} is too tired to play right now.',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    final bool canDo = energyLevel >= _selectedActivity.energyCost &&
        !_gameOver &&
        !_gameWon;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          // Scrollable activity chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _PetActivity.values.map((activity) {
                final selected = _selectedActivity == activity;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _gameOver || _gameWon
                        ? null
                        : () => setState(() => _selectedActivity = activity),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? activity.color
                            : activity.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? activity.color
                              : activity.color.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(activity.icon,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            activity.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : activity.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Activity details row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedActivity.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedActivity.icon}  ${_selectedActivity.label}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _selectedActivity.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedActivity.description,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 10),
                // Stat effect pills
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _EffectPill(
                        label: 'Energy',
                        value: _selectedActivity.energyCost > 0
                            ? '-${_selectedActivity.energyCost}'
                            : '+${_selectedActivity.energyGain}',
                        positive: _selectedActivity.energyCost == 0),
                    if (_selectedActivity.energyGain > 0 &&
                        _selectedActivity.energyCost > 0)
                      _EffectPill(
                          label: 'Energy Gain',
                          value: '+${_selectedActivity.energyGain}',
                          positive: true),
                    _EffectPill(
                        label: 'Happiness',
                        value: _selectedActivity.happinessDelta >= 0
                            ? '+${_selectedActivity.happinessDelta}'
                            : '${_selectedActivity.happinessDelta}',
                        positive: _selectedActivity.happinessDelta >= 0),
                    _EffectPill(
                        label: 'Hunger',
                        value: _selectedActivity.hungerDelta >= 0
                            ? '+${_selectedActivity.hungerDelta}'
                            : '${_selectedActivity.hungerDelta}',
                        positive: _selectedActivity.hungerDelta <= 0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: canDo
                  ? _selectedActivity.color
                  : const Color(0xFFD1D1D6),
              borderRadius: BorderRadius.circular(14),
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: canDo ? _doActivity : null,
              child: Text(
                canDo
                    ? 'Do Activity  ${_selectedActivity.icon}'
                    : 'Not enough energy',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: canDo ? Colors.white : Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinProgress() {
    final progress = _winTimeCounter / 180;
    return _GlassCard(
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay happy to win!',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E)),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF34C759),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_winSecondsLeft seconds remaining',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _gameWon
            ? const Color(0xFF34C759).withOpacity(0.10)
            : const Color(0xFFFF3B30).withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _gameWon
              ? const Color(0xFF34C759).withOpacity(0.35)
              : const Color(0xFFFF3B30).withOpacity(0.35),
        ),
      ),
      child: Column(
        children: [
          Text(_gameWon ? '🏆' : '💔',
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            _gameWon ? 'You Won!' : 'Game Over',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _gameWon
                  ? const Color(0xFF34C759)
                  : const Color(0xFFFF3B30),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _gameWon
                ? '${petName.split(' ').first} is thriving and loves you! 🎉'
                : '${petName.split(' ').first} ran away… try again.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            color: _gameWon
                ? const Color(0xFF34C759)
                : const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(14),
            padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            onPressed: _resetGame,
            child: const Text(
              'Play Again',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────── Settings ───────────────────────────────────

class SettingsScreen extends StatefulWidget {
  final String currentName;
  final ValueChanged<String> onRename;
  final VoidCallback onReset;

  const SettingsScreen({
    super.key,
    required this.currentName,
    required this.onRename,
    required this.onReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    widget.onRename(name);
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pet renamed to "$name"!'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmReset() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Reset Stats'),
        content: const Text(
            'This will reset all vitals to default. Your pet\'s name will be kept.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              widget.onReset();
              Navigator.of(context).pop();
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Game reset!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('Reset'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmNewGame() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Start Over'),
        content: const Text(
            'Return to the start screen to create a brand new pet.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                    builder: (_) => const OnboardingScreen()),
              );
            },
            child: const Text('Start Over'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        backgroundColor: const Color(0xFFF2F2F7),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Done',
            style: TextStyle(
                color: Color(0xFF6C63FF), fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsSectionLabel('PET NAME'),
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      controller: _nameCtrl,
                      placeholder: 'Enter a new name',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1C1E),
                      ),
                      decoration: const BoxDecoration(),
                      padding: EdgeInsets.zero,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const Divider(height: 20, thickness: 0.5),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: _saveName,
                        child: const Text('Save Name',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingsSectionLabel('GAME'),
              _GlassCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.arrow_counterclockwise,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'Reset Stats',
                      subtitle: 'Keep name, reset all vitals to 50',
                      onTap: _confirmReset,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _SettingsTile(
                      icon: CupertinoIcons.plus_circle,
                      iconColor: const Color(0xFFFF9F0A),
                      title: 'New Game',
                      subtitle: 'Start fresh with a new pet name',
                      onTap: _confirmNewGame,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingsSectionLabel('HOW TO PLAY'),
              _GlassCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.checkmark_seal_fill,
                      iconColor: const Color(0xFF34C759),
                      title: 'Win Condition',
                      subtitle: 'Keep happiness above 80 for 3 minutes',
                      onTap: null,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _SettingsTile(
                      icon: CupertinoIcons.cursor_rays,
                      iconColor: const Color(0xFFFF3B30),
                      title: 'Pet Tip',
                      subtitle: 'Tap your pet to give a little love!',
                      onTap: null,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _SettingsTile(
                      icon: CupertinoIcons.sportscourt_fill,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'Activities',
                      subtitle: 'Run, Sleep, Bath, Train & Nap each affect stats differently',
                      onTap: null,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _SettingsTile(
                      icon: CupertinoIcons.flame,
                      iconColor: const Color(0xFFFF9F0A),
                      title: 'Hunger Warning',
                      subtitle: 'High hunger drains happiness over time',
                      onTap: null,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Petchi v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Shared Widgets ─────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool invert;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.invert = false,
  });

  Color get _barColor {
    if (!invert) return color;
    if (value < 40) return const Color(0xFF34C759);
    if (value < 70) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('$value%',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93))),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value / 100),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (_, val, __) => LinearProgressIndicator(
                    value: val,
                    minHeight: 8,
                    backgroundColor: Colors.grey[100],
                    color: _barColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: enabled ? Colors.white : Colors.grey[400],
                  size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: enabled
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  final String text;
  const _SettingsSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF8E8E93))),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(CupertinoIcons.chevron_right,
                  size: 16, color: Color(0xFF8E8E93)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── Activity Model ─────────────────────────────────

enum _PetActivity { run, sleep, bath, train, nap }

extension _PetActivityX on _PetActivity {
  String get label {
    switch (this) {
      case _PetActivity.run:   return 'Run';
      case _PetActivity.sleep: return 'Sleep';
      case _PetActivity.bath:  return 'Bath';
      case _PetActivity.train: return 'Train';
      case _PetActivity.nap:   return 'Nap';
    }
  }

  String get icon {
    switch (this) {
      case _PetActivity.run:   return '🏃';
      case _PetActivity.sleep: return '😴';
      case _PetActivity.bath:  return '🛁';
      case _PetActivity.train: return '💪';
      case _PetActivity.nap:   return '💤';
    }
  }

  String get reaction {
    switch (this) {
      case _PetActivity.run:   return '🏃';
      case _PetActivity.sleep: return '😴';
      case _PetActivity.bath:  return '✨';
      case _PetActivity.train: return '💪';
      case _PetActivity.nap:   return '💤';
    }
  }

  String get description {
    switch (this) {
      case _PetActivity.run:
        return 'A good run! Burns energy & increases hunger but boosts happiness.';
      case _PetActivity.sleep:
        return 'A full night\'s rest. Restores lots of energy with a happiness boost.';
      case _PetActivity.bath:
        return 'Squeaky clean! Happiness goes up with minimal energy cost.';
      case _PetActivity.train:
        return 'Intense workout. Big happiness boost but very tiring and hungry.';
      case _PetActivity.nap:
        return 'A quick nap. Gently recovers energy without much hunger impact.';
    }
  }

  Color get color {
    switch (this) {
      case _PetActivity.run:   return const Color(0xFF6C63FF);
      case _PetActivity.sleep: return const Color(0xFF5856D6);
      case _PetActivity.bath:  return const Color(0xFF32ADE6);
      case _PetActivity.train: return const Color(0xFFFF3B30);
      case _PetActivity.nap:   return const Color(0xFF34C759);
    }
  }

  int get energyCost {
    switch (this) {
      case _PetActivity.run:   return 25;
      case _PetActivity.sleep: return 0;
      case _PetActivity.bath:  return 5;
      case _PetActivity.train: return 40;
      case _PetActivity.nap:   return 0;
    }
  }

  int get energyGain {
    switch (this) {
      case _PetActivity.run:   return 0;
      case _PetActivity.sleep: return 60;
      case _PetActivity.bath:  return 0;
      case _PetActivity.train: return 0;
      case _PetActivity.nap:   return 25;
    }
  }

  int get happinessDelta {
    switch (this) {
      case _PetActivity.run:   return 15;
      case _PetActivity.sleep: return 10;
      case _PetActivity.bath:  return 20;
      case _PetActivity.train: return 25;
      case _PetActivity.nap:   return 5;
    }
  }

  int get hungerDelta {
    switch (this) {
      case _PetActivity.run:   return 15;
      case _PetActivity.sleep: return 5;
      case _PetActivity.bath:  return 0;
      case _PetActivity.train: return 20;
      case _PetActivity.nap:   return 5;
    }
  }
}

// ──────────────────────────── Effect Pill Widget ─────────────────────────────

class _EffectPill extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;

  const _EffectPill({
    required this.label,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}