import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ClassSelector extends StatelessWidget {
  final int selectedClass;
  final Function(int) onClassSelected;
  
  const ClassSelector({
    super.key,
    required this.selectedClass,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: appProvider.availableClasses.length,
            itemBuilder: (context, index) {
              final classNumber = appProvider.availableClasses[index];
              final isSelected = classNumber == selectedClass;
              
              return GestureDetector(
                onTap: () => onClassSelected(classNumber),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 16),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4A90E2), Color(0xFF9B59B6)],
                          )
                        : null,
                    color: isSelected 
                        ? null
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected 
                        ? null
                        : Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Class',
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white
                              : const Color(0xFF7F8C8D),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$classNumber',
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white
                              : const Color(0xFF2C3E50),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
