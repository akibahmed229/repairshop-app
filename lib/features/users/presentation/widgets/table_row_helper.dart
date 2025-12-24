// Helper method for the TableRow
import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

TableRow buildTableRow(
  BuildContext context, {
  required String username,
  required String roles,
  required String editIcon,
  VoidCallback? onEditTap,
  bool isHeader = false,
}) {
  final textStyle = TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    color: AppPallete.whiteColor,
  );
  final padding = EdgeInsets.symmetric(
    vertical: isHeader ? 12 : 8,
    horizontal: 8,
  );

  return TableRow(
    decoration: BoxDecoration(
      color: isHeader ? AppPallete.borderColor.withValues(alpha: 0.5) : null,
    ),
    children: [
      Padding(
        padding: padding,
        child: Text(username, style: textStyle),
      ),
      Padding(
        padding: padding,
        // Convert List<String> roles to a comma-separated string for display
        child: Text(roles, style: textStyle),
      ),
      Center(
        child: isHeader
            ? Padding(
                padding: padding,
                child: Text(editIcon, style: textStyle),
              )
            : IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: AppPallete.whiteColor,
                ),
                onPressed: onEditTap,
              ),
      ),
    ],
  );
}
