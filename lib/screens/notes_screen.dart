import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Notes',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Access your study materials anytime',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'All Notes'),
                    Tab(text: 'Favorites'),
                    Tab(text: 'Recent'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllNotesTab(),
                      _buildFavoritesTab(),
                      _buildRecentTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new note functionality
          _showAddNoteDialog();
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAllNotesTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final subjects = appProvider.getSubjectsForClass(appProvider.selectedClass);
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: subject['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subject['icon'],
                    color: subject['color'],
                  ),
                ),
                title: Text(
                  subject['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Class ${appProvider.selectedClass} • ${_getChapterCount(subject['name'])} Chapters',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: _buildChapterList(subject['name'], appProvider.selectedClass),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildChapterList(String subject, int classNumber) {
    // Mock chapter data
    final chapters = _getMockChapters(subject, classNumber);
    
    return chapters.map((chapter) {
      return ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
          child: Text(
            '${chapters.indexOf(chapter) + 1}',
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(chapter),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_border, size: 20),
              onPressed: () {
                // Add to favorites
              },
            ),
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              onPressed: () {
                // Download PDF
              },
            ),
          ],
        ),
        onTap: () {
          // Open chapter content
          Navigator.of(context).pushNamed(
            '/chapter-content',
            arguments: {
              'subject': subject,
              'chapter': chapter,
              'classNumber': classNumber,
            },
          );
        },
      );
    }).toList();
  }

  Widget _buildFavoritesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon on any note to add it to favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your recently viewed notes will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getMockChapters(String subject, int classNumber) {
    // Mock chapter data - in a real app, this would come from Firebase
    switch (subject) {
      case 'Math':
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
      case 'Science':
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
      case 'History':
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
      case 'English':
        return [
          'A Pact with the Sun',
          'The Friendly Mongoose',
          'The Shepherd\'s Treasure',
          'The Old-Clock Shop',
          'Tansen',
          'The Monkey and the Crocodile',
          'The Wonder Called Sleep',
          'A Pact with the Sun',
          'What Happened to the Reptiles',
          'A Strange Wrestling Match',
        ];
      default:
        return ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4', 'Chapter 5'];
    }
  }

  int _getChapterCount(String subject) {
    return _getMockChapters(subject, 6).length;
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Personal Note'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Note Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save note functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note saved successfully!'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
