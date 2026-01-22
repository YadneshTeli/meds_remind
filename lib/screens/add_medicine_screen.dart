import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../utils/app_colors.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  DateTime? _selectedTime;
  bool _isLoading = false;
  
  // Frequency fields
  FrequencyType _frequencyType = FrequencyType.daily;
  final Set<int> _selectedDays = {}; // 1=Monday to 7=Sunday
  int _intervalDays = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _saveMedicine() async {
    print('💊 [AddMedicineScreen] Attempting to save medicine...');
    
    if (!_formKey.currentState!.validate()) {
      print('⚠️ [AddMedicineScreen] Form validation failed');
      return;
    }

    if (_selectedTime == null) {
      print('⚠️ [AddMedicineScreen] No time selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    // Validate frequency-specific fields
    if (_frequencyType == FrequencyType.specificDays && _selectedDays.isEmpty) {
      print('⚠️ [AddMedicineScreen] No days selected for specific days frequency');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    print('📝 [AddMedicineScreen] Form validated successfully');
    print('   Name: ${_nameController.text.trim()}');
    print('   Dose: ${_doseController.text.trim()}');
    print('   Time: $_selectedTime');
    print('   Frequency: $_frequencyType');
    print('   Selected Days: $_selectedDays');
    print('   Interval: $_intervalDays');

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<MedicineProvider>(context, listen: false).addMedicine(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        time: _selectedTime!,
        frequency: _frequencyType,
        selectedDays: _selectedDays.toList()..sort(),
        intervalDays: _frequencyType == FrequencyType.interval ? _intervalDays : null,
      );
      print('✅ [AddMedicineScreen] Medicine saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine added successfully'),
            backgroundColor: AppColors.teal,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      print('❌ [AddMedicineScreen] Error saving medicine: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding medicine: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Add Medicine',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medicine Name
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medicine Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Aspirin',
                          prefixIcon: const Icon(
                            Icons.medical_services,
                            color: AppColors.teal,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.teal,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter medicine name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dose
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dose',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _doseController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 1 tablet, 10ml',
                          prefixIcon: const Icon(
                            Icons.medication,
                            color: AppColors.teal,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.teal,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter dose';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Picker
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: _selectTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.teal,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _selectedTime == null
                                  ? 'Select time'
                                  : _formatTime(_selectedTime!),
                              style: TextStyle(
                                fontSize: 18,
                                color: _selectedTime == null
                                    ? AppColors.grey
                                    : AppColors.black,
                                fontWeight: _selectedTime == null
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Frequency Selector
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Daily option
                      RadioListTile<FrequencyType>(
                        title: const Text('Every day'),
                        value: FrequencyType.daily,
                        groupValue: _frequencyType,
                        activeColor: AppColors.teal,
                        onChanged: (value) {
                          setState(() {
                            _frequencyType = value!;
                          });
                        },
                      ),
                      
                      // Specific days option
                      RadioListTile<FrequencyType>(
                        title: const Text('Specific days'),
                        value: FrequencyType.specificDays,
                        groupValue: _frequencyType,
                        activeColor: AppColors.teal,
                        onChanged: (value) {
                          setState(() {
                            _frequencyType = value!;
                          });
                        },
                      ),
                      
                      // Show day checkboxes when specific days is selected
                      if (_frequencyType == FrequencyType.specificDays) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildDayChip('Mon', 1),
                              _buildDayChip('Tue', 2),
                              _buildDayChip('Wed', 3),
                              _buildDayChip('Thu', 4),
                              _buildDayChip('Fri', 5),
                              _buildDayChip('Sat', 6),
                              _buildDayChip('Sun', 7),
                            ],
                          ),
                        ),
                      ],
                      
                      // Interval option
                      RadioListTile<FrequencyType>(
                        title: const Text('Every X days'),
                        value: FrequencyType.interval,
                        groupValue: _frequencyType,
                        activeColor: AppColors.teal,
                        onChanged: (value) {
                          setState(() {
                            _frequencyType = value!;
                          });
                        },
                      ),
                      
                      // Show interval selector when interval is selected
                      if (_frequencyType == FrequencyType.interval) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Text('Every'),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: _intervalDays.toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.teal,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final days = int.tryParse(value);
                                    if (days != null && days > 0) {
                                      setState(() {
                                        _intervalDays = days;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(_intervalDays == 1 ? 'day' : 'days'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          'Save Medicine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build day selection chip
  Widget _buildDayChip(String label, int dayNumber) {
    final isSelected = _selectedDays.contains(dayNumber);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(dayNumber);
          } else {
            _selectedDays.remove(dayNumber);
          }
        });
      },
      selectedColor: AppColors.teal,
      checkmarkColor: AppColors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
