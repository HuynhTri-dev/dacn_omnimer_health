import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/health_profile_empty_view.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/health_profile_folder.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/health_profile_header.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/my_goal_section.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_form/personal_profile_form_page.dart';

class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({super.key});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  HealthProfile? _currentProfile;
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectCheckupDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentProfile?.checkupDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return child!;
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      final dateStr = DateFormat('yyyy-MM-dd').format(picked);
      if (context.mounted) {
        context.read<HealthProfileBloc>().add(
          GetHealthProfileByDateEvent(dateStr),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              context.read<HealthProfileBloc>().add(
                GetHealthProfileGoalsEvent(state.user.id),
              );
            }
          },
          child: BlocConsumer<HealthProfileBloc, HealthProfileState>(
            listener: (context, state) {
              if (state is HealthProfileLoaded) {
                setState(() {
                  _currentProfile = state.profile;
                  _selectedDate = state.profile.checkupDate;
                });
              } else if (state is HealthProfileError ||
                  state is HealthProfileEmpty) {
                setState(() {
                  _currentProfile = null;
                });
              } else if (state is HealthProfileDeleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa hồ sơ thành công'),
                    backgroundColor: AppColors.success,
                  ),
                );
                setState(() {
                  _currentProfile = null;
                });
                context.read<HealthProfileBloc>().add(
                  const GetLatestHealthProfileEvent(),
                );
              }
            },
            builder: (context, state) {
              if (state is HealthProfileLoading && _currentProfile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      builder: (context, authState) {
                        String? imageUrl;
                        if (authState is AuthenticationAuthenticated) {
                          imageUrl = authState.user.imageUrl;
                        }
                        return HealthProfileHeaderWidget(
                          profile: _currentProfile,
                          onDateTap: () => _selectCheckupDate(context),
                          imageUrl: imageUrl,
                          selectedDate: _selectedDate,
                          onCreateTap: () => _navigateToCreateProfile(context),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _currentProfile != null
                              ? BlocBuilder<
                                  AuthenticationBloc,
                                  AuthenticationState
                                >(
                                  builder: (context, authState) {
                                    String? imageUrl;
                                    if (authState
                                        is AuthenticationAuthenticated) {
                                      imageUrl = authState.user.imageUrl;
                                    }
                                    return HealthProfileFolder(
                                      profile: _currentProfile!,
                                      imageUrl: imageUrl,
                                    );
                                  },
                                )
                              : const HealthProfileEmptyView(),
                          const SizedBox(height: 24),
                          const MyGoalSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToCreateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PersonalProfileFormPage(initialDate: _selectedDate),
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        // Refresh data after creation
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
        context.read<HealthProfileBloc>().add(
          GetHealthProfileByDateEvent(dateStr),
        );
      }
    });
  }
}
