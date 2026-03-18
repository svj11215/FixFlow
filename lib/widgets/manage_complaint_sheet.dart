import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/complaint_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'complaint_image_widget.dart';

class ManageComplaintSheet extends StatefulWidget {
  final ComplaintModel complaint;
  final Future<bool> Function(String status, String note) onUpdate;

  const ManageComplaintSheet({
    super.key,
    required this.complaint,
    required this.onUpdate,
  });

  @override
  State<ManageComplaintSheet> createState() => _ManageComplaintSheetState();
}

class _ManageComplaintSheetState extends State<ManageComplaintSheet> {
  late String _selectedStatus;
  late TextEditingController _noteController;
  bool _isUpdating = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
    _noteController = TextEditingController(text: widget.complaint.resolutionNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<Color> _getButtonGradient(String status) {
    switch (status) {
      case 'Resolved':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'Rejected':
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case 'Pending':
        return [const Color(0xFF94A3B8), const Color(0xFF64748B)];
      case 'In Progress':
      default:
        return [AppColors.primary, AppColors.accentTeal];
    }
  }

  IconData _getButtonIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle_outline;
      case 'Rejected':
        return Icons.cancel_outlined;
      case 'Pending':
        return Icons.schedule;
      case 'In Progress':
      default:
        return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(widget.complaint.status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manage Complaint',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.background, height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  const Text(
                    'COMPLAINT DETAILS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),

                  // Details info card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.background),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Title', widget.complaint.title, isFirst: true),
                        _buildDetailRow('Description', widget.complaint.description),
                        _buildDetailRow('Category', widget.complaint.category),
                        _buildDetailRow('Location', widget.complaint.location),
                        _buildDetailRow('Submitted By', widget.complaint.userName),
                        _buildDetailRow('Date Submitted', Helpers.formatDate(widget.complaint.createdAt), isLast: true),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 100.ms),

                  const SizedBox(height: 16),

                  // Status banner
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.complaint.status,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const Spacer(),
                        const Text('Current Status', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 200.ms).slideX(begin: 0.1),

                  const SizedBox(height: 24),

                  // Attached Photo Section
                  const Text(
                    'ATTACHED PHOTO',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),

                  if (widget.complaint.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ComplaintImageWidget(imageUrl: widget.complaint.imageUrl),
                    ).animate().fadeIn(duration: 350.ms, delay: 300.ms)
                  else
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined, color: Color(0xFFCBD5E1), size: 20),
                            SizedBox(width: 8),
                            Text('No image attached', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Update Section
                  const Text(
                    'UPDATE COMPLAINT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Update Status',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: AppStatuses.statuses.map((status) {
                      final color = AppColors.statusColor(status);
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Text(status, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedStatus = value);
                    },
                  ).animate().fadeIn(duration: 350.ms, delay: 400.ms),

                  const SizedBox(height: 16),

                  // Resolution Note
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: 'Resolution Note',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      hintText: 'Add notes about how the issue was resolved or why it was rejected...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 500.ms),

                  const SizedBox(height: 8),

                  // Update Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 52,
                    margin: const EdgeInsets.only(top: 8, bottom: 24),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _showSuccess ? [AppColors.secondary, const Color(0xFF059669)] : _getButtonGradient(_selectedStatus)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (_showSuccess ? AppColors.secondary : _getButtonGradient(_selectedStatus).first).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating || _showSuccess ? null : _handleUpdate,
                        icon: _isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : _showSuccess
                                ? const Icon(Icons.check_circle, color: Colors.white)
                                : Icon(_getButtonIcon(_selectedStatus), color: Colors.white),
                        label: Text(
                          _showSuccess ? 'Updated Successfully!' : 'Update Complaint',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isFirst = false, bool isLast = false}) {
    return Column(
      children: [
        if (!isFirst) const Divider(height: 1, color: Color(0xFFF8FAFC)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);
    final success = await widget.onUpdate(_selectedStatus, _noteController.text.trim());
    if (mounted) {
      setState(() => _isUpdating = false);
      if (success) {
        setState(() => _showSuccess = true);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Text(AppStrings.complaintUpdated, style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }
}
