import 'package:go_router/go_router.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/goal_setup_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/library/screens/domain_screen.dart';
import '../../features/library/screens/subject_screen.dart';
import '../../features/library/screens/topic_screen.dart';
import '../../features/library/screens/book_screen.dart';
import '../../features/library/screens/chapter_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/progress/screens/topic_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/my_uploads_screen.dart';
import '../../features/flashcards/screens/review_session_screen.dart';
import '../../features/flashcards/screens/card_result_screen.dart';
import '../../features/flashcards/screens/flashcard_set_screen.dart';
import '../../features/pdf_upload/screens/pdf_upload_screen.dart';
import '../../features/pdf_upload/screens/pdf_preview_screen.dart';
import '../../features/pdf_upload/screens/pdf_result_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/orbit_bottom_nav.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
      routes: [
        GoRoute(
          path: 'goals',
          name: RouteNames.goals,
          builder: (context, state) => const GoalSetupScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/auth/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/signup',
      name: RouteNames.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/verify-email',
      name: RouteNames.verifyEmail,
      builder: (context, state) => const VerifyEmailScreen(),
    ),

    // shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => OrbitBottomNav(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/library',
            name: RouteNames.library,
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: ':domainId',
                name: RouteNames.domain,
                builder: (context, state) => DomainScreen(
                  domainId: state.pathParameters['domainId']!,
                ),
                routes: [
                  GoRoute(
                    path: ':subjectId',
                    name: RouteNames.subject,
                    builder: (context, state) => SubjectScreen(
                      domainId: state.pathParameters['domainId']!,
                      subjectId: state.pathParameters['subjectId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: ':bookId',
                        name: RouteNames.book,
                        builder: (context, state) => BookScreen(
                          domainId: state.pathParameters['domainId']!,
                          subjectId: state.pathParameters['subjectId']!,
                          bookId: state.pathParameters['bookId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: ':chapterId',
                            name: RouteNames.chapter,
                            builder: (context, state) => ChapterScreen(
                              domainId: state.pathParameters['domainId']!,
                              subjectId: state.pathParameters['subjectId']!,
                              bookId: state.pathParameters['bookId']!,
                              chapterId: state.pathParameters['chapterId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/search',
            name: RouteNames.search,
            builder: (context, state) => const SearchScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/progress',
            name: RouteNames.progress,
            builder: (context, state) => const ProgressScreen(),
            routes: [
              GoRoute(
                path: ':topicId',
                name: RouteNames.topicDetail,
                builder: (context, state) => TopicDetailScreen(
                  topicId: state.pathParameters['topicId']!,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/profile',
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.editProfile,
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'uploads',
                name: RouteNames.myUploads,
                builder: (context, state) => const MyUploadsScreen(),
              ),
            ],
          ),
        ]),
      ],
    ),

    // full-screen routes (no bottom nav)
    GoRoute(
      path: '/review/:topicId',
      name: RouteNames.review,
      builder: (context, state) => ReviewSessionScreen(
        topicId: state.pathParameters['topicId']!,
      ),
      routes: [
        GoRoute(
          path: 'result',
          name: RouteNames.cardResult,
          builder: (context, state) => CardResultScreen(
            topicId: state.pathParameters['topicId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/flashcards/:topicId',
      name: RouteNames.flashcardSet,
      builder: (context, state) => FlashcardSetScreen(
        topicId: state.pathParameters['topicId']!,
      ),
    ),
    GoRoute(
      path: '/upload',
      name: RouteNames.upload,
      builder: (context, state) => const PdfUploadScreen(),
      routes: [
        GoRoute(
          path: 'preview/:uploadId',
          name: RouteNames.uploadPreview,
          builder: (context, state) => PdfPreviewScreen(
            uploadId: state.pathParameters['uploadId']!,
          ),
        ),
        GoRoute(
          path: 'result/:uploadId',
          name: RouteNames.uploadResult,
          builder: (context, state) => PdfResultScreen(
            uploadId: state.pathParameters['uploadId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/leaderboard',
      name: RouteNames.leaderboard,
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => const SplashScreen(),
);
