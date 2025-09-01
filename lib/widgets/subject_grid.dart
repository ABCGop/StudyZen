import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/subject_notes_screen.dart';

class SubjectGrid extends StatelessWidget {
  const SubjectGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final subjects = appProvider.getSubjectsForClass(appProvider.selectedClass);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4, // Increased aspect ratio to reduce height
            crossAxisSpacing: 8, // Reduced spacing
            mainAxisSpacing: 8, // Reduced spacing
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            
            return GestureDetector(
              onTap: () {
                appProvider.setSelectedSubject(subject['name']);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SubjectNotesScreen(
                      subject: subject['name'],
                      classNumber: appProvider.selectedClass,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: subject['color'],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: subject['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(12), // Reduced padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40, // Reduced icon container size
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            subject['icon'],
                            color: Colors.white,
                            size: 22, // Reduced icon size
                          ),
                        ),
                        
                        const SizedBox(height: 8), // Reduced spacing
                        
                        Text(
                          subject['name'],
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 14, // Reduced font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 2), // Reduced spacing
                        
                        Text(
                          '${_getChapterCount(subject['name'], appProvider.selectedClass)} Chapters',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11, // Reduced font size
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            );
          },
        );
      },
    );
  }

  int _getChapterCount(String subject, int classNumber) {
    // Mock chapter counts based on typical NCERT structure
    final Map<String, Map<int, int>> chapterCounts = {
      'Math': {6: 14, 7: 15, 8: 16, 9: 15, 10: 15, 11: 16, 12: 13},
      'Science': {6: 16, 7: 18, 8: 18, 9: 15, 10: 16, 11: 22, 12: 16},
      'History': {6: 12, 7: 10, 8: 10, 9: 8, 10: 8, 11: 11, 12: 15},
      'English': {6: 10, 7: 10, 8: 12, 9: 11, 10: 10, 11: 8, 12: 8},
      'Geography': {6: 8, 7: 9, 8: 6, 9: 6, 10: 7, 11: 16, 12: 12},
      'Physics': {11: 15, 12: 15},
      'Chemistry': {11: 14, 12: 16},
      'Biology': {11: 22, 12: 16},
    };
    
    return chapterCounts[subject]?[classNumber] ?? 10;
  }
}
