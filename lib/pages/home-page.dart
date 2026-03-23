import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/proxys/login-proxy.dart';
import 'package:story/models/story-model.dart';
import 'package:story/proxys/story-proxy.dart';

class HomePage extends StatefulWidget {
  final Function(StoryModel) onTapped;
  final Function() onLogout;
  final Function() onUpload;
  final int refreshCount;
  const HomePage({
    super.key,
    required this.onTapped,
    required this.onLogout,
    required this.onUpload,
    this.refreshCount = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nickname = '';
  late Future<List<StoryModel>> _stories;

  @override
  void initState() {
    super.initState();
    getNickname();
    getStories();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshCount != widget.refreshCount) {
      setState(() {
        getStories();
      });
    }
  }

  Future<void> getNickname() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      nickname = sharedPreferences.getString('name') ?? '';
    });
  }

  Future<void> getStories() async {
    _stories = StoryProxy().getAllStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<StoryModel>>(
        future: _stories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final stories = snapshot.data!;
            return ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return GestureDetector(
                  onTap: () {
                    widget.onTapped(story);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          story.photoUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(story.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No stories found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onUpload,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final proxy = LoginProxy();
              await proxy.doLogout();
              if (!mounted) return;
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
