import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/core/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    this.onBook,
  });

  final DoctorProfile doctor;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.doctorProfile(doctor.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProfileAvatar(
                imageUrl: doctor.photoUrl,
                initials: AppFormatters.initials(doctor.fullName),
                radius: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doctor.specialization,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 15, color: scheme.error.withValues(alpha: 0.8)),
                        const SizedBox(width: 2),
                        Text('${doctor.rating.toStringAsFixed(1)} (${doctor.reviewCount})'),
                        const SizedBox(width: 10),
                        Icon(Icons.location_on_outlined,
                            size: 15, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            doctor.city.isEmpty ? 'Available online' : doctor.city,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(doctor.consultationFee),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (onBook != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: onBook,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(72, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Book'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
