import 'package:flutter/material.dart';
import 'package:mobile/features/workout/workout_detail_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/services/play_state.dart';
import 'package:mobile/features/onboarding/launch_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.todayPlan,
  });

  /// currentIndex is for PAGES (0..3): Home, Streak, Insights, Profile
  final int currentIndex;

  /// called with PAGE index (0..3)
  final ValueChanged<int> onTap;

  final DayPlan todayPlan;

  static const int _playNavIndex = 2;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _playCtrl;
  late final Animation<double> _playScale;

  Future<void> _onPlayPressed() async {
    // Press-down already happened onTapDown; now do pop+settle before navigating
    _playCtrl.stop();
    _playCtrl.value = 0.45; // start at end of press-down
    await _playCtrl.animateTo(
      1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );

    if (!mounted) return;
    await _handleTap(context, BottomNav._playNavIndex);
  }

  @override
  void initState() {
    super.initState();

    _playCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    // 0.0 -> 1.0 timeline:
    // 0-0.45: press down to 0.92
    // 0.45-0.75: pop up to 1.06
    // 0.75-1.0: settle to 1.0
    _playScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.06,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_playCtrl);
  }

  @override
  void dispose() {
    _playCtrl.dispose();
    super.dispose();
  }

  PlayStateResult _playResult() {
    final profile = LocalStorageService.getUserProfile();
    return PlayStateResolver.resolveForToday(
      profile: profile,
      todayPlan: widget.todayPlan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // if you already added height earlier, keep it:
      // height: 64,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: BottomNavigationBar(
        currentIndex: _pageToNavIndex(widget.currentIndex),
        onTap: (navIndex) {
          // ✅ ignore Play here; Play icon handles it so animation can run
          if (navIndex == BottomNav._playNavIndex) return;
          _handleTap(context, navIndex);
        },

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4442D9),
        unselectedItemColor: Colors.black38,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 24,
        items: [
          _item(Icons.home, "Home", 0),
          _item(Icons.local_fire_department, "Streak", 1),
          _centerPlayItem(),
          _item(Icons.insights, "Insights", 3),
          _item(Icons.person, "Profile", 4),
        ],
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, int navIndex) async {
    if (navIndex == BottomNav._playNavIndex) {
      // ✅ run a tiny tap animation even if user taps via BottomNavigationBar itself
      await _tapPlayAnimation();

      final r = _playResult();

      switch (r.state) {
        case PlayState.ready:
          final mins =
              LocalStorageService.getUserProfile()?.workoutDuration ?? 40;

          final id = PlayStateResolver.workoutIdFor(
            widget.todayPlan.date, // ✅ use plan date
            widget.todayPlan,
          );

          if (!context.mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(
                dayLabel: "Today",
                title: widget.todayPlan.title,
                totalTimeText: widget.todayPlan.isWorkoutDay
                    ? "$mins mins"
                    : "Rest day",
                workoutId: id,
                warmupCount: 0,
              ),
            ),
          );
          return;

        case PlayState.restDay:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Rest day today 😴")));
          return;

        case PlayState.notSetup:
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LaunchScreen()));
          return;

        case PlayState.notGenerated:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Workout not ready yet. Open Home to prepare it."),
            ),
          );
          return;
      }
    }

    final pageIndex = _navToPageIndex(navIndex);
    widget.onTap(pageIndex);
  }

  Future<void> _tapPlayAnimation() async {
    // quick press + release
    if (_playCtrl.isAnimating) return;
    await _playCtrl.forward();
    await _playCtrl.reverse();
  }

  /// Nav indexes are: 0,1,2,3,4 (includes play at 2)
  /// Page indexes are: 0,1,2,3 (no play page)
  int _navToPageIndex(int navIndex) {
    return navIndex > BottomNav._playNavIndex ? navIndex - 1 : navIndex;
  }

  int _pageToNavIndex(int pageIndex) {
    return pageIndex >= BottomNav._playNavIndex ? pageIndex + 1 : pageIndex;
  }

  BottomNavigationBarItem _item(IconData icon, String label, int navIndex) {
    final isActive = navIndex == _pageToNavIndex(widget.currentIndex);

    return BottomNavigationBarItem(
      label: "",
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isActive
              ? Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4442D9),
                  ),
                )
              : Icon(icon),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF4442D9) : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _centerPlayItem() {
    final r = _playResult();

    final isRest = r.state == PlayState.restDay;
    final isNotSetup = r.state == PlayState.notSetup;

    Widget? badge;
    if (isRest) {
      badge = const _MiniBadge(text: "Zz");
    } else if (isNotSetup) {
      badge = const _MiniBadge(text: "!");
    }

    // We wrap with GestureDetector so the press feels immediate.
    // It also calls _handleTap with the play index.
    return BottomNavigationBarItem(
      label: "",
      icon: GestureDetector(
        onTapDown: (_) {
          _playCtrl.stop();
          _playCtrl.value = 0.0;
          // run only the "press down" part quickly
          _playCtrl.animateTo(
            0.45,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
          );
        },
        onTapCancel: () {
          // settle back to 1.0 smoothly
          _playCtrl.animateTo(
            1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
          );
        },
        onTapUp: (_) {
          // run the pop + settle
          _playCtrl.animateTo(
            1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
          );
        },
        onTap: _onPlayPressed,

        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _playScale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Opacity(
                    opacity: isRest ? 0.55 : 1,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4442D9),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(right: -2, top: -6, child: badge),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  const _MiniBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
