import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/app_strings.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:url_launcher/url_launcher.dart';

/// Policy type enum
enum PolicyType { privacyPolicy, termsOfService }

/// Screen to display policy documents with markdown rendering and agreement checkbox
class PolicyViewerScreen extends StatefulWidget {
  final PolicyType policyType;

  const PolicyViewerScreen({Key? key, required this.policyType})
    : super(key: key);

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  String _markdownContent = '';
  bool _isLoading = true;
  bool _hasScrolledToEnd = false;
  bool _isAgreed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMarkdownContent();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // If content is short (maxScrollExtent is small), consider it read
    if (_scrollController.position.maxScrollExtent <= 10) {
      if (!_hasScrolledToEnd) {
        setState(() {
          _hasScrolledToEnd = true;
        });
      }
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToEnd) {
        setState(() {
          _hasScrolledToEnd = true;
        });
      }
    }
  }

  Future<void> _loadMarkdownContent() async {
    try {
      final String assetPath = widget.policyType == PolicyType.privacyPolicy
          ? 'assets/policies/PRIVACY_POLICY.md'
          : 'assets/policies/TERMS_CONDITIONS.md';

      final String content = await rootBundle.loadString(assetPath);
      setState(() {
        _markdownContent = content;
        _isLoading = false;
      });

      // Check if content fits screen after a short delay to allow rendering
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _onScroll();
      });
    } catch (e) {
      setState(() {
        _markdownContent = '${AppStrings.errorLoading}$e';
        _isLoading = false;
      });
    }
  }

  String get _title => widget.policyType == PolicyType.privacyPolicy
      ? AppStrings.privacyPolicy
      : AppStrings.termsOfService;

  void _onAgreeChanged(bool? value) {
    if (value == null) return;

    setState(() {
      _isAgreed = value;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Markdown content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusMd,
                      child: Markdown(
                        controller: _scrollController,
                        data: _markdownContent,
                        selectable: true,
                        padding: EdgeInsets.all(AppSpacing.md),
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            _launchUrl(href);
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          h1: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                          h2: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          h3: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          p: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                            height: 1.6,
                          ),
                          listBullet: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                          strong: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          em: textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(
                              0.3,
                            ),
                            borderRadius: AppRadius.radiusSm,
                            border: Border(
                              left: BorderSide(
                                color: colorScheme.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          horizontalRuleDecoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outline.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          a: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          // Scroll hint
          if (!_hasScrolledToEnd && !_isLoading)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    AppStrings.scrollToRead,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Agreement section
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Checkbox
                  InkWell(
                    onTap: _hasScrolledToEnd || _isAgreed
                        ? () => _onAgreeChanged(!_isAgreed)
                        : null,
                    borderRadius: AppRadius.radiusSm,
                    child: Opacity(
                      opacity: _hasScrolledToEnd || _isAgreed ? 1.0 : 0.5,
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _isAgreed
                              ? colorScheme.primaryContainer.withOpacity(0.3)
                              : colorScheme.surfaceContainerHighest.withOpacity(
                                  0.3,
                                ),
                          borderRadius: AppRadius.radiusSm,
                          border: Border.all(
                            color: _isAgreed
                                ? colorScheme.primary.withOpacity(0.5)
                                : colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              onChanged: _hasScrolledToEnd || _isAgreed
                                  ? _onAgreeChanged
                                  : null,
                              activeColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${AppStrings.iAgree}$_title',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _isAgreed
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAgreed
                          ? () => Navigator.pop(context, true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isAgreed
                            ? AppStrings.continueBtn
                            : AppStrings.readToAgree,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isAgreed
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
