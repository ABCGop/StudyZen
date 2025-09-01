import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SubjectNotesScreen extends StatefulWidget {
  final String subject;
  final int classNumber;

  const SubjectNotesScreen({
    super.key,
    required this.subject,
    required this.classNumber,
  });

  @override
  State<SubjectNotesScreen> createState() => _SubjectNotesScreenState();
}

class _SubjectNotesScreenState extends State<SubjectNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> chapters = [];
  List<String> filteredChapters = [];

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  void _loadChapters() {
    chapters = _getMockChapters();
    filteredChapters = List.from(chapters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} - Class ${widget.classNumber}'),
        backgroundColor: _getSubjectColor(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download all chapters as PDF
              _showDownloadDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSubjectColor().withOpacity(0.1),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chapters...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterChapters('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterChapters,
            ),
          ),
          
          // Chapters List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredChapters.length,
              itemBuilder: (context, index) {
                final chapter = filteredChapters[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getSubjectColor(),
                      child: Text(
                        '${chapters.indexOf(chapter) + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      chapter,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Chapter ${chapters.indexOf(chapter) + 1} • NCERT',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'read':
                            _openChapter(chapter);
                            break;
                          case 'download':
                            _downloadChapter(chapter);
                            break;
                          case 'favorite':
                            _toggleFavorite(chapter);
                            break;
                          case 'ask_ai':
                            _askAIAboutChapter(chapter);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'read',
                          child: Row(
                            children: [
                              Icon(Icons.book),
                              SizedBox(width: 8),
                              Text('Read Chapter'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download),
                              SizedBox(width: 8),
                              Text('Download PDF'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(Icons.favorite_border),
                              SizedBox(width: 8),
                              Text('Add to Favorites'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'ask_ai',
                          child: Row(
                            children: [
                              Icon(Icons.smart_toy),
                              SizedBox(width: 8),
                              Text('Ask AI about this'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _openChapter(chapter),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _askAIAboutSubject();
        },
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text(
          'Ask AI',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Color _getSubjectColor() {
    switch (widget.subject.toLowerCase()) {
      case 'math':
        return AppTheme.mathColor;
      case 'science':
        return AppTheme.scienceColor;
      case 'history':
        return AppTheme.historyColor;
      case 'english':
        return AppTheme.englishColor;
      default:
        return AppTheme.primaryBlue;
    }
  }

  List<String> _getMockChapters() {
    switch (widget.subject.toLowerCase()) {
      case 'math':
        return [
          'Knowing Our Numbers',
          'Whole Numbers',
          'Playing with Numbers',
          'Basic Geometrical Ideas',
          'Understanding Elementary Shapes',
          'Integers',
          'Fractions',
          'Decimals',
          'Data Handling',
          'Mensuration',
          'Algebra',
          'Ratio and Proportion',
          'Symmetry',
          'Practical Geometry',
        ];
      case 'science':
        return [
          'Food: Where Does it Come From?',
          'Components of Food',
          'Fibre to Fabric',
          'Sorting Materials into Groups',
          'Separation of Substances',
          'Changes Around Us',
          'Getting to Know Plants',
          'Body Movements',
          'The Living Organisms',
          'Motion and Measurement',
          'Light, Shadows and Reflections',
          'Electricity and Circuits',
          'Fun with Magnets',
          'Water',
          'Air Around Us',
          'Garbage In, Garbage Out',
        ];
      case 'history':
        return [
          'What, Where, How and When?',
          'From Hunting-Gathering to Growing Food',
          'In the Earliest Cities',
          'What Books and Burials Tell Us',
          'Kingdoms, Kings and an Early Republic',
          'New Questions and Ideas',
          'Ashoka, The Emperor Who Gave Up War',
          'Vital Villages, Thriving Towns',
          'Traders, Kings and Pilgrims',
          'New Empires and Kingdoms',
          'Buildings, Paintings and Books',
        ];
      case 'english':
        return [
          'A Pact with the Sun',
          'The Friendly Mongoose',
          'The Shepherd\'s Treasure',
          'The Old-Clock Shop',
          'Tansen',
          'The Monkey and the Crocodile',
          'The Wonder Called Sleep',
          'What Happened to the Reptiles',
          'A Strange Wrestling Match',
        ];
      default:
        return ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4', 'Chapter 5'];
    }
  }

  void _filterChapters(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredChapters = List.from(chapters);
      } else {
        filteredChapters = chapters
            .where((chapter) => chapter.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _openChapter(String chapter) {
    Navigator.of(context).pushNamed(
      '/chapter-content',
      arguments: {
        'subject': widget.subject,
        'chapter': chapter,
        'classNumber': widget.classNumber,
      },
    );
  }

  void _downloadChapter(String chapter) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "$chapter"...'),
        action: SnackBarAction(
          label: 'View Downloads',
          onPressed: () {
            // Navigate to downloads
          },
        ),
      ),
    );
  }

  void _toggleFavorite(String chapter) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$chapter" to favorites'),
      ),
    );
  }

  void _askAIAboutChapter(String chapter) {
    Navigator.of(context).pushNamed(
      '/ai-chat',
      arguments: 'Explain the chapter "$chapter" from ${widget.subject} Class ${widget.classNumber}',
    );
  }

  void _askAIAboutSubject() {
    Navigator.of(context).pushNamed(
      '/ai-chat',
      arguments: 'I need help with ${widget.subject} for Class ${widget.classNumber}. What topics should I focus on?',
    );
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download All Chapters'),
        content: Text(
          'Do you want to download all ${chapters.length} chapters of ${widget.subject} Class ${widget.classNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading all ${chapters.length} chapters...'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
