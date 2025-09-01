import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearchSubmitted;
  final String? hintText;
  final bool enableVoiceSearch;
  final VoidCallback? onVoicePressed;
  
  const SearchBarWidget({
    super.key,
    this.onSearchSubmitted,
    this.hintText,
    this.enableVoiceSearch = true,
    this.onVoicePressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _setupSearchSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setupSearchSuggestions() {
    // Popular search terms for NCERT content
    _suggestions = [
      'Mathematics Class 10',
      'Science Class 9',
      'History Ancient India',
      'Geography Climate',
      'Physics Motion',
      'Chemistry Acids Bases',
      'Biology Life Processes',
      'English Grammar',
      'Hindi Vyakaran',
      'Social Science',
      'Algebra Solutions',
      'Geometry Theorems',
      'Political Science',
      'Economics',
    ];
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search notes, topics, or ask AI...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 22,
                ),
              ),
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              _updateSuggestions(value);
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _performSearch(value.trim());
              }
            },
          ),
        ),
        if (_isSearching && _searchController.text.isNotEmpty)
          _buildSuggestions(context),
      ],
    );
  }

  Widget _buildSuffixIcon() {
    if (_searchController.text.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.enableVoiceSearch)
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Icon(
                  Icons.mic_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: () {
                  if (widget.onVoicePressed != null) {
                    widget.onVoicePressed!();
                  } else {
                    _handleVoiceSearch();
                  }
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _isSearching = false;
                });
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ),
        ],
      );
    } else {
      return widget.enableVoiceSearch
          ? Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.mic_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: () {
                  if (widget.onVoicePressed != null) {
                    widget.onVoicePressed!();
                  } else {
                    _handleVoiceSearch();
                  }
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            )
          : const SizedBox.shrink();
    }
  }

  Widget _buildSuggestions(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredSuggestions = _suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .take(5)
        .toList();

    if (filteredSuggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
        itemBuilder: (context, index) {
          final suggestion = filteredSuggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.search_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
            title: Text(
              suggestion,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_outward_rounded,
              color: Colors.grey[500],
              size: 16,
            ),
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
              setState(() {
                _isSearching = false;
              });
            },
          );
        },
      ),
    );
  }

  void _performSearch(String query) {
    print('Searching for: $query');
    
    // Hide suggestions
    setState(() {
      _isSearching = false;
    });
    
    // Remove focus
    _focusNode.unfocus();
    
    // Call the callback if provided
    if (widget.onSearchSubmitted != null) {
      widget.onSearchSubmitted!(query);
      return;
    }
    
    // Default behavior - navigate to AI chat with search query
    Navigator.of(context).pushNamed('/ai-chat').then((_) {
      // You can pass the search query to AI chat screen
      // This would require updating the AI chat screen to accept initial messages
    });
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $query'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _handleVoiceSearch() {
    // This will be handled by the parent widget or voice provider
    print('Voice search activated');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Voice search activated!'),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
