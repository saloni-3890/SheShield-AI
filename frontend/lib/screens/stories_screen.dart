import 'package:flutter/material.dart';
import '../services/story_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  late Future<List<dynamic>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() {
    _storiesFuture = StoryService.getStories();
  }

  Future<void> _refreshStories() async {
    setState(() {
      _loadStories();
    });
  }

  void _openStory(dynamic story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  story['title'] ?? 'Untitled Story',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      story['isAnonymous'] == true
                          ? 'Anonymous'
                          : 'Community Member',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    story['category'] ?? 'OTHER',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  story['content'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSubmitStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubmitStoryScreen(),
      ),
    ).then((_) {
      _refreshStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real Stories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitStory,
        icon: const Icon(Icons.edit),
        label: const Text('Share Story'),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshStories,
        child: FutureBuilder<List<dynamic>>(
          future: _storiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Unable to load stories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadStories();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final stories = snapshot.data ?? [];

            if (stories.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Icon(
                      Icons.auto_stories_outlined,
                      size: 65,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No stories available yet.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Be the first to share your experience.',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _openStory(story),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['title'] ?? 'Untitled Story',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            story['content'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  story['category'] ?? 'OTHER',
                                  style: TextStyle(
                                    color: Colors.purple.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              Text(
                                story['isAnonymous'] == true
                                    ? 'Anonymous'
                                    : 'Community Member',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


// ============================================================
// SUBMIT STORY SCREEN
// ============================================================

class SubmitStoryScreen extends StatefulWidget {
  const SubmitStoryScreen({super.key});

  @override
  State<SubmitStoryScreen> createState() => _SubmitStoryScreenState();
}

class _SubmitStoryScreenState extends State<SubmitStoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _category = 'SAFETY';
  bool _anonymous = true;
  bool _loading = false;

  final List<String> _categories = [
    'SAFETY',
    'HARASSMENT',
    'TRAVEL',
    'COLLEGE',
    'WORKPLACE',
    'ONLINE_SAFETY',
    'OTHER',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitStory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await StoryService.createStory(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _category,
        isAnonymous: _anonymous,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Story submitted for review.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Story'),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your experience can help someone else.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Share a real experience, safety lesson, or helpful tip with the community.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Story Title',
                  hintText: 'Give your story a meaningful title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Your Story',
                  hintText: 'Describe your experience...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write your story';
                  }

                  if (value.trim().length < 20) {
                    return 'Please provide a little more detail';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Post Anonymously',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Your identity will not be shown publicly.',
                ),
                value: _anonymous,
                onChanged: (value) {
                  setState(() {
                    _anonymous = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitStory,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'Submit Story',
                          style: TextStyle(
                            fontSize: 16,
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
}