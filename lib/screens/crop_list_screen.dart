import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/crop_options.dart';
import '../models/crop.dart';
import '../providers/crop_provider.dart';
import '../services/activity_logs_service.dart';
import '../services/crop_actions_service.dart';
import '../services/session_service.dart';
import 'crops_screen.dart';
import '../app_extensions.dart';

class CropListScreen extends ConsumerStatefulWidget {
  const CropListScreen({super.key});

  @override
  ConsumerState<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends ConsumerState<CropListScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      ref.read(cropSearchQueryProvider.notifier).state =
          searchController.text.trim();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Page Header
            _buildPageHeader(),

            // Search Bar
            _buildSearchBar(),

            // Crop List
            Expanded(child: _buildCropList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCropDialog,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      // decoration: BoxDecoration(color: AppColors.primaryGreenDark),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
           Expanded(
            child: Text(
              context.l10n.homeActionCrops,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _showCropStats,
            icon: const Icon(
              Icons.analytics_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: context.l10n.lblSearch,
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon:
              searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCropList() {
    final cropsAsync = ref.watch(cropsProvider);
    final filteredCrops = ref.watch(filteredCropsProvider);

    return cropsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Unable to load crops.\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
      data: (_) {
        if (filteredCrops.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredCrops.length,
          itemBuilder: (context, index) {
            return _buildCropCard(filteredCrops[index]);
          },
        );
      },
    );
  }

  Widget _buildCropCard(Crop crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToCropDetail(crop),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      crop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: AppColors.textSecondary,
                    onPressed: () => _deleteCrop(crop),
                    tooltip: 'Delete crop',
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                '${context.l10n.areaLabel} ${crop.areaAcres?.toStringAsFixed(1) ?? 'N/A'} acres',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatSowingLine(crop.sowDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCrop(Crop crop) async {
    final farmId = int.tryParse(crop.id);
    if (farmId == null) return;

    try {
      await ref.read(cropListNotifierProvider.notifier).deleteCrop(
            farmId: farmId,
          );
      await ActivityLogsService.clearCacheForFarm(farmId);
      await CropActionsService.clearCacheForFarm(farmId);
      ref.invalidate(cropsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete crop. $e')),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Text(
            context.l10n.farmEmptyState,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Add your first crop to get started',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddCropDialog,
            icon: const Icon(Icons.add),
            label:  Text(context.l10n.addCropTitle),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatSowingLine(DateTime sowDate) {
    final daysSince = DateTime.now().difference(sowDate).inDays;
    final dayLabel = daysSince == 1 ? 'day' : 'days';
    return 'Sown $daysSince $dayLabel ago • ${_formatDate(sowDate)}';
  }


  void _navigateToCropDetail(Crop crop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CropsScreen(crop: crop)),
    );
  }

  Future<void> _showAddCropDialog() async {
    final newCrop = await Navigator.push<Crop>(
      context,
      MaterialPageRoute(builder: (context) => const AddCropPage()),
    );

    if (newCrop == null) return;

    ref.invalidate(cropsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.addCropSuccessful(newCrop.name)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showCropStats() {
    final crops = ref.read(cropsProvider).valueOrNull ?? const <Crop>[];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title:  Text(context.l10n.cropStatisticsTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatItem(context.l10n.totalcropsLabel, crops.length.toString()),
                _buildStatItem(
                  context.l10n.totalFarmAreaLabel,
                  '${crops.fold(0.0, (sum, crop) => sum + (crop.areaAcres ?? 0)).toStringAsFixed(1)} acres',
                ),
                _buildStatItem(
                  context.l10n.activeCropsLabel,
                  crops.where((c) => c.stage != 'harvest').length.toString(),
                ),
                _buildStatItem(
                  context.l10n.readyForHarvestLabel,
                  crops.where((c) => c.stage == 'harvest').length.toString(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.btnClose),
              ),
            ],
          ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class AddCropPage extends ConsumerStatefulWidget {
  const AddCropPage({super.key});

  @override
  ConsumerState<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends ConsumerState<AddCropPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _typeController = TextEditingController();
  final _landController = TextEditingController();
  final List<String> _areaUnits = const ['Acre', 'Hectare', 'Beegha', 'KM2'];
  String _selectedAreaUnit = 'Acre';
  bool _isSubmitting = false;

  DateTime _selectedDate = DateTime.now();
  final List<String> _cropTypes = CropOptions.supportedCropTypes;

  @override
  void dispose() {
    _labelController.dispose();
    _typeController.dispose();
    _landController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _pickCropType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final searchController = TextEditingController();
        var filtered = List<String>.from(_cropTypes);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void updateFilter(String query) {
              final normalized = query.trim().toLowerCase();
              setSheetState(() {
                filtered =
                    _cropTypes
                        .where(
                          (type) => type.toLowerCase().contains(normalized),
                        )
                        .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  TextField(
                    controller: searchController,
                    decoration:  InputDecoration(
                      labelText: context.l10n.lblSearch,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: updateFilter,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final type = filtered[index];
                        return ListTile(
                          title: Text(type),
                          onTap: () => Navigator.pop(context, type),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;

    setState(() {
      _typeController.text = selected;
    });
  }
  
  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final landValue = double.tryParse(_landController.text.trim());
    if (landValue == null || landValue <= 0) return;
    setState(() => _isSubmitting = true);

    final cropName = _labelController.text.trim();
    final cropType = _typeController.text.trim();
    final areaAcres = _convertToAcres(landValue, _selectedAreaUnit);

    int? farmId;
    try {
      farmId = await ref.read(cropListNotifierProvider.notifier).addCrop(
        name: cropName,
        cropType: cropType,
        area: areaAcres,
        sowDate: _selectedDate,
        stage: 'sowing',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(context.l10n.cropSaveError)),
      );
      return;
    }

    final address = await SessionService.getUserAddress();
    if (!mounted) return;
    final location = [
      address['village'],
      address['district'],
      address['state'],
    ].where((v) => v != null && v.trim().isNotEmpty).join(', ');

    final newCrop = Crop(
      id: (farmId ?? DateTime.now().millisecondsSinceEpoch).toString(),
      name: cropName,
      type: cropType,
      sowDate: _selectedDate,
      stage: 'sowing',
      areaAcres: areaAcres,
      actionsHistory: const [],
      location: location.isEmpty ? 'Not provided' : location,
    );

    setState(() => _isSubmitting = false);
    Navigator.pop(context, newCrop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title:  Text(context.l10n.addCropTitle),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _labelController,
                        decoration:  InputDecoration(
                          labelText: context.l10n.lblSearch,
                          hintText: context.l10n.cropLabelHint,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.cropLabelHintError;

                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _typeController,
                        readOnly: true,
                        decoration:  InputDecoration(
                          labelText: context.l10n.cropTypeLabel,
                          hintText: context.l10n.cropTypeHint,
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: _pickCropType,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.cropTypeHint;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _landController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration:  InputDecoration(
                                labelText: context.l10n.sownAreaLabel,
                                hintText: context.l10n.sownAreaHint,
                                prefixIcon: Icon(Icons.square_foot),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                final number = double.tryParse(text);
                                if (number == null || number <= 0) {
                                  return context.l10n.sownAreaHintError;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 140,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedAreaUnit,
                              isExpanded: true,
                              decoration:  InputDecoration(
                                labelText: context.l10n.unitLabel,
                              ),
                              items:
                                  _areaUnits
                                      .map(
                                        (unit) => DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(unit),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedAreaUnit = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title:  Text(context.l10n.plantedDateLabel),
                        subtitle: Text(_formatDate(_selectedDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                          : Text(context.l10n.addCropTitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _convertToAcres(double area, String unit) {
    switch (unit.toLowerCase()) {
      case 'acre':
        return area;
      case 'hectare':
        return area * 2.47105;
      case 'beegha':
        return area * 0.625;
      case 'km2':
        return area * 247.105;
      default:
        return area;
    }
  }
}