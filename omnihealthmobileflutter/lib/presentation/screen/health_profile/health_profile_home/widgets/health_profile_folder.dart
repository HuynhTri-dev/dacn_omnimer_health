import 'package:flutter/material.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/advance_tab_view.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/fitness_tab_view.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/summary_tab_view.dart';

class HealthProfileFolder extends StatefulWidget {
  final HealthProfile profile;
  final String? imageUrl;

  const HealthProfileFolder({super.key, required this.profile, this.imageUrl});

  @override
  State<HealthProfileFolder> createState() => _HealthProfileFolderState();
}

class _HealthProfileFolderState extends State<HealthProfileFolder> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Folder Tabs
        SizedBox(
          height: 40,
          child: Row(
            children: [
              _buildTab('Summary', 0),
              _buildTab('Fitness', 1),
              _buildTab('Advance', 2),
            ],
          ),
        ),
        // Folder Body
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Subtle slide from right with fade
                final offsetAnimation =
                    Tween<Offset>(
                      begin: const Offset(0.03, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: isSelected
              ? [] // No shadow for active tab to blend with body
              : [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, -1),
                  ),
                ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return SummaryTabView(
          profile: widget.profile,
          imageUrl: widget.imageUrl,
        );
      case 1:
        return FitnessTabView(profile: widget.profile);
      case 2:
        return AdvanceTabView(profile: widget.profile);
      default:
        return const SizedBox();
    }
  }
}
