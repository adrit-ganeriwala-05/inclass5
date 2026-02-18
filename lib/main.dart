// ============================================================
// In-Class Activity #5: Digital Pet App
// Name:       Adrit Ganeriwala
// Username:   aganeriwala1
// Student ID: 002703111
// Course:     MAD – Mobile Application Development
// Date:       02/18/2026
// Description: A Flutter digital pet simulation app that
//              demonstrates StatefulWidget, setState(), Timer,
//              ColorFiltered, and activity-based state management.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOS-style widgets (buttons, dialogs, nav bar)
import 'package:flutter/services.dart';  // HapticFeedback and SystemChrome
import 'dart:async';                     // Timer for auto-hunger loop
import 'dart:math';                      // max() used for win countdown

void main() {
  // Ensure Flutter engine is initialized before calling any platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Style the system status bar to match the light app theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PetApp());
}

// ─────────────────────────────── App Root ────────────────────────────────────

// Root StatelessWidget — sets up MaterialApp theme and launches OnboardingScreen
class PetApp extends StatelessWidget {
  const PetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug ribbon in the corner
      title: 'Petchi',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display', // iOS system font for native feel
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Purple brand color
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS system gray background
      ),
      home: const OnboardingScreen(), // Start at the name entry screen
    );
  }
}

// ─────────────────────────────── Onboarding ──────────────────────────────────

// First screen the user sees — lets them name their pet before entering the game
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // Controller to read the text the user types for the pet name
  final TextEditingController _nameController = TextEditingController();

  // AnimationController drives the fade + slide entrance animation
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;    // Fades the whole screen in from 0 to 1
  late Animation<Offset> _slideAnim;  // Slides content up from slightly below

  @override
  void initState() {
    super.initState();

    // Set up a 900ms entrance animation that plays once on load
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    // Slide from 15% below normal position up to final position
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward(); // Start the animation immediately
  }

  @override
  void dispose() {
    // Always dispose controllers to free resources and prevent memory leaks
    _animCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Called when the user taps "Meet Your Pet" or presses enter
  void _continue() {
    final name = _nameController.text.trim();

    // Validate — pet name cannot be empty
    if (name.isEmpty) {
      HapticFeedback.lightImpact(); // Subtle error feedback
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

    HapticFeedback.mediumImpact(); // Confirm tap feedback

    // Navigate to the main game screen, passing the name the user typed
    // pushReplacement means the user cannot go back to the onboarding screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => PetHomeScreen(petName: name),
        // Smooth fade transition instead of the default slide
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

                  // App icon with gradient background and drop shadow
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
                        // Fallback emoji if the asset file is missing
                        errorBuilder: (_, __, ___) => const Text(
                          '🐾',
                          style: TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App name title
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

                  // Tagline subtitle
                  Text(
                    'Your virtual companion awaits.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[500],
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(flex: 2),

                  // Card containing the pet name text field
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section label above the text field
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

                        // CupertinoTextField for iOS-native keyboard behavior
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
                          decoration: const BoxDecoration(), // Remove default border
                          padding: EdgeInsets.zero,
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _continue(), // Allow keyboard "done" to proceed
                        ),
                        const Divider(height: 20, thickness: 0.5),

                        // Helper hint text below the field
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

                  // Primary CTA button — proceeds to the game
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

// The main game screen — receives the pet name from OnboardingScreen
class PetHomeScreen extends StatefulWidget {
  final String petName;
  const PetHomeScreen({super.key, required this.petName});

  @override
  State<PetHomeScreen> createState() => _PetHomeScreenState();
}

// StatefulWidget is required here because the pet's stats change over time
// and each change must trigger a UI rebuild via setState()
class _PetHomeScreenState extends State<PetHomeScreen>
    with TickerProviderStateMixin {

  // ── Core game state variables ──────────────────────────────────────────────
  late String petName;          // Current display name of the pet
  int happinessLevel = 50;      // 0–100: drives mood color and win condition
  int hungerLevel = 50;         // 0–100: increases over time automatically
  int energyLevel = 100;        // 0–100: consumed by play and activities

  // Currently selected activity from the Activities card
  _PetActivity _selectedActivity = _PetActivity.run;

  // Timer fires every second to run the auto-hunger and win/loss checks
  Timer? _timer;

  // Tracks how many consecutive seconds happiness has been above 80
  // Win condition: must stay above 80 for 180 seconds (3 minutes)
  int _winTimeCounter = 0;

  bool _gameOver = false; // True when hunger=100 AND happiness<=10
  bool _gameWon = false;  // True when _winTimeCounter reaches 180

  // ── Animation controllers ──────────────────────────────────────────────────

  // Bounce: pet scales up briefly when interacted with
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  // Reaction: emoji pops up above the pet after each interaction
  late AnimationController _reactionCtrl;
  late Animation<double> _reactionScale;

  // Float: pet gently bobs up and down in an idle loop
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // Stores the current reaction emoji displayed above the pet
  String _reactionEmoji = '';

  @override
  void initState() {
    super.initState();
    petName = widget.petName; // Copy name from the widget parameter into state

    // Bounce animation — scales the pet to 112% then back to normal
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    // Reaction emoji animation — scales from 0 to full size with elastic overshoot
    _reactionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _reactionScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reactionCtrl, curve: Curves.elasticOut),
    );

    // Float animation — loops forever, moving pet -6 to +6 pixels vertically
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // reverse: true makes it oscillate smoothly
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _startTimer(); // Begin the game loop
  }

  @override
  void dispose() {
    // CRITICAL: Cancel the timer when this widget is removed from the tree.
    // Without this, the timer keeps firing after dispose and causes a
    // "setState() called after dispose()" exception — a memory leak.
    _timer?.cancel();

    // Dispose all animation controllers to free GPU/CPU resources
    _bounceCtrl.dispose();
    _reactionCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ── Game Loop ──────────────────────────────────────────────────────────────

  // Starts a 1-second repeating timer that drives the game's automatic behavior
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Do nothing if the game has already ended
      if (_gameOver || _gameWon) return;

      // setState() is required here — without it, variable changes would not
      // trigger a UI rebuild and the screen would appear frozen
      setState(() {
        // Every 30 ticks (30 seconds), automatically increase hunger by 5
        if (timer.tick % 30 == 0) {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);

          // If hunger is maxed out, start draining happiness as a penalty
          if (hungerLevel >= 100) {
            happinessLevel = (happinessLevel - 20).clamp(0, 100);
          }
        }

        // Win condition check: happiness must stay above 80 for 180 consecutive seconds
        if (happinessLevel > 80) {
          _winTimeCounter++;
          if (_winTimeCounter >= 180) {
            _gameWon = true;
            HapticFeedback.mediumImpact(); // Celebrate!
          }
        } else {
          // Reset the counter — happiness must be continuously above 80
          _winTimeCounter = 0;
        }

        // Loss condition: hunger is maxed AND happiness is critically low
        if (hungerLevel >= 100 && happinessLevel <= 10) {
          _gameOver = true;
          HapticFeedback.heavyImpact(); // Strong feedback for game over
        }
      });
    });
  }

  // ── Animation Helpers ──────────────────────────────────────────────────────

  // Plays the bounce animation forward then reverses it back to normal size
  void _triggerBounce() {
    _bounceCtrl.forward().then((_) => _bounceCtrl.reverse());
  }

  // Shows an emoji reaction above the pet, then fades it out after a delay
  void _showReaction(String emoji) {
    setState(() => _reactionEmoji = emoji);
    _reactionCtrl.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _reactionCtrl.reverse(); // Only reverse if widget still exists
      });
    });
  }

  // ── User Actions ───────────────────────────────────────────────────────────

  // Play button: costs 20 energy, boosts happiness, increases hunger slightly
  void _playWithPet() {
    // Guard: cannot play if game is over, won, or not enough energy
    if (_gameOver || _gameWon || energyLevel < 20) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    _triggerBounce();
    _showReaction('🎉');

    // clamp(0, 100) ensures values never go below 0 or above 100
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      energyLevel = (energyLevel - 20).clamp(0, 100);
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
    });
  }

  // Feed button: reduces hunger, restores some energy, updates happiness
  void _feedPet() {
    if (_gameOver || _gameWon) return;
    HapticFeedback.mediumImpact();
    _triggerBounce();
    _showReaction('😋');

    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      energyLevel = (energyLevel + 10).clamp(0, 100);

      // If hunger is already very low, pet isn't hungry — feeding too much
      // makes them unhappy; otherwise feeding a hungry pet boosts happiness
      if (hungerLevel < 30) {
        happinessLevel = (happinessLevel - 10).clamp(0, 100);
      } else {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
      }
    });
  }

  // Tap-to-pet: small happiness boost, triggered by tapping the pet avatar
  void _petThePet() {
    if (_gameOver || _gameWon) return;
    HapticFeedback.lightImpact();
    _triggerBounce();
    _showReaction('💕');

    setState(() {
      happinessLevel = (happinessLevel + 5).clamp(0, 100);
    });
  }

  // Activity button: applies the selected activity's stat effects to the pet
  void _doActivity() {
    if (_gameOver || _gameWon) return;
    final a = _selectedActivity;

    // Check if the pet has enough energy for this specific activity
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
    _showReaction(a.reaction); // Each activity has its own reaction emoji

    // Apply the activity's stat deltas — each activity has different values
    // defined in the _PetActivity extension below
    setState(() {
      happinessLevel = (happinessLevel + a.happinessDelta).clamp(0, 100);
      hungerLevel = (hungerLevel + a.hungerDelta).clamp(0, 100);
      // Net energy = current - cost + any gain (e.g. Sleep costs 0 but gains 60)
      energyLevel = (energyLevel - a.energyCost + a.energyGain).clamp(0, 100);
    });
  }

  // Opens the Settings screen as a push route (user can navigate back)
  void _openSettings() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => SettingsScreen(
          currentName: petName,
          // Callbacks let Settings update state in this parent widget
          onRename: (name) => setState(() => petName = name),
          onReset: _resetGame,
        ),
      ),
    );
  }

  // Resets all game state to defaults without changing the pet name
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

  // ── Derived State (computed from current values) ───────────────────────────

  // Returns a color based on happiness — used for glow, tint, and mood badge
  // This is a getter, not a stored value — it recalculates on every build
  Color get _moodColor {
    if (happinessLevel > 70) return const Color(0xFF34C759); // Green = happy
    if (happinessLevel >= 30) return const Color(0xFFFF9F0A); // Orange = neutral
    return const Color(0xFFFF3B30); // Red = unhappy
  }

  // Text label shown in the mood badge below the pet name
  String get _moodLabel {
    if (happinessLevel > 70) return 'Happy';
    if (happinessLevel >= 30) return 'Neutral';
    return 'Unhappy';
  }

  // Emoji shown alongside the mood label
  String get _moodEmoji {
    if (happinessLevel > 70) return '😄';
    if (happinessLevel >= 30) return '😐';
    return '😢';
  }

  // Seconds remaining until win — only meaningful when happiness > 80
  int get _winSecondsLeft => max(0, 180 - _winTimeCounter);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Every call to setState() causes Flutter to call build() again,
    // reconstructing the widget tree with the latest state values
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // iOS-style rubber band scroll
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  // Pinned app bar that stays visible while scrolling
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      scrolledUnderElevation: 0, // Prevents shadow when content scrolls under it
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
        // Settings gear icon in the top right corner
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

  // Main scrollable body — stacks all the cards vertically
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildPetCard(),       // Pet avatar, name, mood badge
          const SizedBox(height: 16),
          _buildStatsCard(),     // Happiness, hunger, energy progress bars
          const SizedBox(height: 16),
          _buildActionsCard(),   // Play and Feed buttons
          const SizedBox(height: 16),
          _buildActivityCard(),  // Activity selector (Run, Sleep, Bath, etc.)

          // Only show outcome card when game has ended
          if (_gameOver || _gameWon) ...[
            const SizedBox(height: 16),
            _buildOutcomeCard(),
          ],

          // Only show win progress bar when happiness is above 80 and game is ongoing
          if (happinessLevel > 80 && !_gameWon && !_gameOver) ...[
            const SizedBox(height: 12),
            _buildWinProgress(),
          ],
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // Pet card: floating avatar with glow ring, mood badge, and tap interaction
  Widget _buildPetCard() {
    return _GlassCard(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              // Mood glow ring — color changes smoothly with AnimatedContainer
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

              // Pet avatar with float + bounce animations combined
              AnimatedBuilder(
                // Listens to both animations simultaneously
                animation: Listenable.merge([_floatAnim, _bounceAnim]),
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnim.value), // Apply vertical float
                    child: Transform.scale(
                      scale: _bounceAnim.value, // Apply bounce scale
                      child: GestureDetector(
                        onTap: _petThePet, // Tap the pet to show love
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
                              // ColorFiltered tints the image using BlendMode.srcATop
                              // This applies a semi-transparent mood color overlay
                              // without needing separate red/green/yellow image files
                              colorFilter: ColorFilter.mode(
                                _moodColor.withOpacity(0.15),
                                BlendMode.srcATop,
                              ),
                              child: Image.asset(
                                'assets/pet_image.png',
                                height: 88,
                                // Fallback emoji if image asset is not found
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

              // Reaction emoji that pops up above the pet on interaction
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

          // Pet name display
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

          // Mood badge — color and text change based on happiness level
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

          // Hint text encouraging the user to tap the pet
          Text(
            'Tap ${petName.split(' ').first} to show some love!',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Stats card: animated progress bars for happiness, hunger, and energy
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

          // Happiness bar — higher is better, shown in red (heart color)
          _StatRow(
            icon: CupertinoIcons.heart_fill,
            label: 'Happiness',
            value: happinessLevel,
            color: const Color(0xFFFF3B30),
          ),
          const SizedBox(height: 14),

          // Hunger bar — invert: true means high value = red (bad), low = green (good)
          _StatRow(
            icon: CupertinoIcons.flame_fill,
            label: 'Hunger',
            value: hungerLevel,
            color: const Color(0xFFFF9F0A),
            invert: true, // High hunger is bad — bar turns red when full
          ),
          const SizedBox(height: 14),

          // Energy bar — higher is better, shown in green
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

  // Actions card: Play and Feed buttons with enabled/disabled states
  Widget _buildActionsCard() {
    // Play requires at least 20 energy and an active game
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

          // Contextual tip shown only when energy is too low to play
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

  // Activity card: scrollable chip selector + stat effect preview + do button
  Widget _buildActivityCard() {
    // Check if the pet can do the currently selected activity
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

          // Horizontally scrollable row of activity chip buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _PetActivity.values.map((activity) {
                final selected = _selectedActivity == activity;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    // Selecting a chip updates _selectedActivity via setState
                    onTap: _gameOver || _gameWon
                        ? null
                        : () => setState(() => _selectedActivity = activity),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        // Selected chip uses full color; unselected is faded
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
                              // White text on selected, colored text on unselected
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

          // Detail panel showing description and stat effect pills for selected activity
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedActivity.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity title
                Text(
                  '${_selectedActivity.icon}  ${_selectedActivity.label}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _selectedActivity.color,
                  ),
                ),
                const SizedBox(height: 6),

                // Activity description text
                Text(
                  _selectedActivity.description,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 10),

                // Stat effect pills — green = beneficial, red = costly
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Energy pill — shows cost or gain depending on activity type
                    _EffectPill(
                        label: 'Energy',
                        value: _selectedActivity.energyCost > 0
                            ? '-${_selectedActivity.energyCost}'
                            : '+${_selectedActivity.energyGain}',
                        positive: _selectedActivity.energyCost == 0),

                    // Show energy gain separately for activities that both cost and gain
                    if (_selectedActivity.energyGain > 0 &&
                        _selectedActivity.energyCost > 0)
                      _EffectPill(
                          label: 'Energy Gain',
                          value: '+${_selectedActivity.energyGain}',
                          positive: true),

                    // Happiness pill
                    _EffectPill(
                        label: 'Happiness',
                        value: _selectedActivity.happinessDelta >= 0
                            ? '+${_selectedActivity.happinessDelta}'
                            : '${_selectedActivity.happinessDelta}',
                        positive: _selectedActivity.happinessDelta >= 0),

                    // Hunger pill — lower hunger is good, so hungerDelta <= 0 is positive
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

          // "Do Activity" button — color matches selected activity, disables if not enough energy
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

  // Win progress bar — only visible when happiness > 80 and game is ongoing
  Widget _buildWinProgress() {
    final progress = _winTimeCounter / 180; // 0.0 to 1.0 progress value
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
                    value: progress, // Fills from 0 to 1 as counter climbs
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

  // Outcome card — shown when the game is won or lost with a Play Again button
  Widget _buildOutcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Color of the card changes based on win or loss
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
          // Trophy or broken heart emoji based on outcome
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

          // Play Again resets all stats via _resetGame()
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

// Settings screen — rename pet, reset stats, or start a completely new game
class SettingsScreen extends StatefulWidget {
  final String currentName;           // Current pet name passed from parent
  final ValueChanged<String> onRename; // Callback to update name in parent state
  final VoidCallback onReset;          // Callback to reset stats in parent state

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
  late TextEditingController _nameCtrl; // Controls the rename text field

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with the current pet name
    _nameCtrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); // Dispose text controller to prevent memory leak
    super.dispose();
  }

  // Saves the new name and notifies the parent widget via callback
  void _saveName() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return; // Don't allow empty names

    widget.onRename(name); // Updates petName in PetHomeScreen's state
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus(); // Dismiss keyboard after saving
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

  // Shows a confirmation dialog before resetting stats
  void _confirmReset() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Reset Stats'),
        content: const Text(
            'This will reset all vitals to default. Your pet\'s name will be kept.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true, // Renders the button in red
            onPressed: () {
              widget.onReset(); // Calls _resetGame() in the parent
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

  // Shows a confirmation dialog before sending the user back to onboarding
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
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close settings
              // Replace the entire stack with OnboardingScreen
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
      // CupertinoNavigationBar gives an iOS-native top bar with "Done" button
      appBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        backgroundColor: const Color(0xFFF2F2F7),
        border: null, // Remove the default bottom border
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(), // Go back to game
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
              // ── Pet Name Section ──────────────────────────────────────────
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

              // ── Game Section ──────────────────────────────────────────────
              _SettingsSectionLabel('GAME'),
              _GlassCard(
                child: Column(
                  children: [
                    // Reset: keeps name, resets all vitals to 50
                    _SettingsTile(
                      icon: CupertinoIcons.arrow_counterclockwise,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'Reset Stats',
                      subtitle: 'Keep name, reset all vitals to 50',
                      onTap: _confirmReset,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    // New Game: returns to OnboardingScreen for a fresh start
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

              // ── How to Play Section ───────────────────────────────────────
              _SettingsSectionLabel('HOW TO PLAY'),
              _GlassCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.checkmark_seal_fill,
                      iconColor: const Color(0xFF34C759),
                      title: 'Win Condition',
                      subtitle: 'Keep happiness above 80 for 3 minutes',
                      onTap: null, // Info-only tile, no action on tap
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

              // App version footer
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

// Reusable white card with rounded corners and subtle shadow
// Used for every section card throughout the app
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
            color: Colors.black.withOpacity(0.04), // Very subtle shadow
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// A single stat row with icon, label, percentage text, and animated progress bar
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;       // Current value 0–100
  final Color color;     // Icon and default bar color
  final bool invert;     // If true, high value = red (used for hunger)

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.invert = false,
  });

  // For hunger (invert=true): low value = green, medium = orange, high = red
  // For other stats: always use the provided color
  Color get _barColor {
    if (!invert) return color;
    if (value < 40) return const Color(0xFF34C759); // Low hunger = good = green
    if (value < 70) return const Color(0xFFFF9F0A); // Medium hunger = orange
    return const Color(0xFFFF3B30);                 // High hunger = bad = red
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Colored icon badge
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
                  // Numeric percentage on the right
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
                // TweenAnimationBuilder animates the bar smoothly whenever value changes
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

// Large tappable button used in the Actions card (Play and Feed)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;  // Small descriptive text under the label
  final Color color;
  final bool enabled;     // When false, button appears grayed out
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
        onTap: enabled ? onTap : null, // Disable tap when not enabled
        child: AnimatedContainer(
          // AnimatedContainer smoothly transitions between enabled/disabled styles
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
            // Drop shadow only when enabled — disappears when disabled
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

// Section header label used in the Settings screen (e.g. "PET NAME", "GAME")
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

// A single row in the Settings list — icon badge, title, subtitle, optional chevron
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // null = info-only (no tap action)

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
      behavior: HitTestBehavior.opaque, // Makes full row tappable including empty space
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Colored icon badge
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
            // Only show the disclosure chevron if the tile has an action
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

// Enum representing each available pet activity
// Each value has associated properties defined in the extension below
enum _PetActivity { run, sleep, bath, train, nap }

// Extension adds behavior/properties to the enum without a separate class
extension _PetActivityX on _PetActivity {

  // Display name shown on the chip and detail panel
  String get label {
    switch (this) {
      case _PetActivity.run:   return 'Run';
      case _PetActivity.sleep: return 'Sleep';
      case _PetActivity.bath:  return 'Bath';
      case _PetActivity.train: return 'Train';
      case _PetActivity.nap:   return 'Nap';
    }
  }

  // Emoji shown on the chip button
  String get icon {
    switch (this) {
      case _PetActivity.run:   return '🏃';
      case _PetActivity.sleep: return '😴';
      case _PetActivity.bath:  return '🛁';
      case _PetActivity.train: return '💪';
      case _PetActivity.nap:   return '💤';
    }
  }

  // Emoji shown as the pet's reaction when this activity is performed
  String get reaction {
    switch (this) {
      case _PetActivity.run:   return '🏃';
      case _PetActivity.sleep: return '😴';
      case _PetActivity.bath:  return '✨';
      case _PetActivity.train: return '💪';
      case _PetActivity.nap:   return '💤';
    }
  }

  // Short description shown in the activity detail panel
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

  // Accent color for the chip, detail panel, and "Do Activity" button
  Color get color {
    switch (this) {
      case _PetActivity.run:   return const Color(0xFF6C63FF); // Purple
      case _PetActivity.sleep: return const Color(0xFF5856D6); // Indigo
      case _PetActivity.bath:  return const Color(0xFF32ADE6); // Blue
      case _PetActivity.train: return const Color(0xFFFF3B30); // Red
      case _PetActivity.nap:   return const Color(0xFF34C759); // Green
    }
  }

  // Energy spent to perform the activity (0 = free, e.g. Sleep and Nap)
  int get energyCost {
    switch (this) {
      case _PetActivity.run:   return 25;
      case _PetActivity.sleep: return 0;
      case _PetActivity.bath:  return 5;
      case _PetActivity.train: return 40;
      case _PetActivity.nap:   return 0;
    }
  }

  // Energy restored by the activity (only rest activities restore energy)
  int get energyGain {
    switch (this) {
      case _PetActivity.run:   return 0;
      case _PetActivity.sleep: return 60; // Full rest restores most energy
      case _PetActivity.bath:  return 0;
      case _PetActivity.train: return 0;
      case _PetActivity.nap:   return 25; // Quick rest restores partial energy
    }
  }

  // How much happiness changes — positive = increases, negative = decreases
  int get happinessDelta {
    switch (this) {
      case _PetActivity.run:   return 15;
      case _PetActivity.sleep: return 10;
      case _PetActivity.bath:  return 20;
      case _PetActivity.train: return 25;
      case _PetActivity.nap:   return 5;
    }
  }

  // How much hunger changes — positive = more hungry (bad), negative = less hungry (good)
  int get hungerDelta {
    switch (this) {
      case _PetActivity.run:   return 15; // Running makes the pet hungry
      case _PetActivity.sleep: return 5;  // Sleeping increases hunger slightly
      case _PetActivity.bath:  return 0;  // Bathing has no hunger effect
      case _PetActivity.train: return 20; // Training makes the pet very hungry
      case _PetActivity.nap:   return 5;  // Napping has a small hunger effect
    }
  }
}

// ──────────────────────────── Effect Pill Widget ─────────────────────────────

// Small colored badge showing a stat change (e.g. "Happiness +15")
// Green = beneficial change, Red = costly change
class _EffectPill extends StatelessWidget {
  final String label;   // Stat name (e.g. "Energy", "Happiness")
  final String value;   // Change value with sign (e.g. "+15", "-20")
  final bool positive;  // true = green, false = red

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