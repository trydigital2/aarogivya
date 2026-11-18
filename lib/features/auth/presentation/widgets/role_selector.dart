import 'package:aarogivya/features/auth/domain/entities/user_role.dart';
import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: UserRole.values.map((role) {
            final isSelected = role == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role == UserRole.patient ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () => onChanged(role),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primary.withValues(alpha: 0.08)
                          : scheme.surface,
                      border: Border.all(
                        color: isSelected ? scheme.primary : scheme.outline,
                        width: isSelected ? 1.6 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          role.icon,
                          color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          role.label,
                          style: TextStyle(
                            color: isSelected
                                ? scheme.primary
                                : scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
