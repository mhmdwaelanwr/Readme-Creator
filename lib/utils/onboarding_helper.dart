import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/preferences_service.dart';
import '../core/constants/app_colors.dart';

class OnboardingHelper {
  static Future<void> showOnboarding({
    required BuildContext context,
    required GlobalKey componentsKey,
    required GlobalKey canvasKey,
    required GlobalKey settingsKey,
    required GlobalKey exportKey,
  }) async {
    final prefs = PreferencesService();
    final hasSeenOnboarding = await prefs.loadBool(PreferencesService.keyHasSeenOnboarding) ?? false;

    if (hasSeenOnboarding) return;
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorial(context, componentsKey, canvasKey, settingsKey, exportKey, true);
    });
  }

  static void restartOnboarding({
    required BuildContext context,
    required GlobalKey componentsKey,
    required GlobalKey canvasKey,
    required GlobalKey settingsKey,
    required GlobalKey exportKey,
  }) {
    _startTutorial(context, componentsKey, canvasKey, settingsKey, exportKey, false);
  }

  static void _startTutorial(BuildContext context, GlobalKey k1, GlobalKey k2, GlobalKey k3, GlobalKey k4, bool savePrefs) {
    final targets = _createTargets(context, k1, k2, k3, k4);
    
    if (!targets.every((t) => t.keyTarget?.currentContext != null)) return;

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0F172A),
      opacityShadow: 0.9,
      paddingFocus: 15,
      pulseEnable: true,
      onFinish: () {
        if (savePrefs) PreferencesService().saveBool(PreferencesService.keyHasSeenOnboarding, true);
      },
      onSkip: () {
        if (savePrefs) PreferencesService().saveBool(PreferencesService.keyHasSeenOnboarding, true);
        return true;
      },
      textSkip: "SKIP TOUR",
      textStyleSkip: GoogleFonts.inter(
        color: Colors.white60, 
        fontWeight: FontWeight.w800, 
        letterSpacing: 1.5,
        fontSize: 13,
      ),
    ).show(context: context);
  }

  static List<TargetFocus> _createTargets(BuildContext context, GlobalKey k1, GlobalKey k2, GlobalKey k3, GlobalKey k4) {
    return [
      _buildTarget(
        context,
        "components", 
        k1, 
        "01",
        "Components Library", 
        "This is your creative arsenal. Drag high-quality Markdown elements—from headings to social badges—and drop them directly into your workflow.", 
        ContentAlign.right,
        Icons.auto_awesome_mosaic_rounded,
      ),
      _buildTarget(
        context,
        "canvas", 
        k2, 
        "02",
        "Interactive Canvas", 
        "The heart of your project. Visualize your README in real-time. Use intuitive drag-and-drop to reorder, duplicate, or refine your content layout.", 
        ContentAlign.bottom,
        Icons.gesture_rounded,
      ),
      _buildTarget(
        context,
        "settings", 
        k3, 
        "03",
        "Precision Settings", 
        "Tailor every detail here. Select any element on the canvas to unlock its dedicated properties. Switch to 'Preview' to see the clean Markdown code.", 
        ContentAlign.left,
        Icons.tune_rounded,
      ),
      _buildTarget(
        context,
        "export", 
        k4, 
        "04",
        "Global Export Hub", 
        "Ready for production? Securely export your work as a structured ZIP file or push it directly to your GitHub repository with one click.", 
        ContentAlign.bottom, 
        Icons.rocket_launch_rounded,
        isCircle: true,
      ),
    ];
  }

  static TargetFocus _buildTarget(BuildContext context, String id, GlobalKey key, String step, String title, String desc, ContentAlign align, IconData icon, {bool isCircle = false}) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: isCircle ? ShapeLightFocus.Circle : ShapeLightFocus.RRect,
      radius: 20,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: id == "settings" ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(maxWidth: 380),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.98),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GUIDE $step",
                                  style: GoogleFonts.inter(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w900, 
                                    color: AppColors.primary,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                                Text(
                                  title, 
                                  style: GoogleFonts.poppins(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.w800, 
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        desc, 
                        style: GoogleFonts.inter(
                          fontSize: 15, 
                          color: Colors.white.withOpacity(0.75), 
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          if (id != "components")
                            IconButton(
                              onPressed: () => controller.previous(),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                              color: Colors.white38,
                              tooltip: "Previous",
                            ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => controller.next(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F172A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  id == "export" ? "LAUNCH" : "CONTINUE",
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                                ),
                                const SizedBox(width: 10),
                                Icon(id == "export" ? Icons.rocket_rounded : Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
